import SwiftUI
import UIDesign

/// A view that describes one session and what a person can do about it.
struct SessionDetailScreen: View {
    /// The most lines the summary takes until a person asks for the rest.
    private static let collapsedSummaryLines = 4

    /// How much of the width the artwork takes beside the heading.
    private static let artworkShare: CGFloat = 0.4

    /// The shortest a speaker's nameplate stands, so it is a comfortable tap
    /// target.
    private static let minimumTapHeight: CGFloat = 44

    /// The session this screen describes.
    let session: SampleSession

    /// The action that shows a speaker's page.
    let showSpeaker: (SamplePerson) -> Void

    /// Whether the summary shows in full when the screen appears.
    private let opensSummaryExpanded: Bool

    /// Whether the screen has a compact or a regular width.
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// Whether this person favourited the session.
    @State private var isFavorite: Bool

    /// Whether the venue page is pushed, to find the session's room.
    @State private var showsVenue = false

    /// Creates a screen for one session.
    ///
    /// - Parameters:
    ///   - session: The session this screen describes.
    ///   - opensSummaryExpanded: Whether the summary shows in full when the
    ///     screen appears.
    ///   - showSpeaker: The action that shows a speaker's page.
    init(
        session: SampleSession,
        opensSummaryExpanded: Bool = false,
        showSpeaker: @escaping (SamplePerson) -> Void,
    ) {
        self.session = session
        self.opensSummaryExpanded = opensSummaryExpanded
        self.showSpeaker = showSpeaker
        _isFavorite = State(initialValue: session.isFavorite)
    }

    var body: some View {
        List {
            // The artwork and the title are the screen's subject rather than
            // a list of facts about it, so they sit on the page with no card
            // and no separators between them. At a regular width the artwork
            // sits beside the heading, so the page's first screen holds the
            // facts and not only a picture.
            Section {
                if horizontalSizeClass == .regular {
                    HStack(alignment: .top, spacing: .large) {
                        artwork
                            .containerRelativeFrame(.horizontal) { width, _ in
                                width * Self.artworkShare
                            }

                        headingWithSpeakers
                    }
                } else {
                    artwork
                        .listRowInsets(EdgeInsets())

                    headingWithSpeakers
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section("About") {
                ExpandableText(
                    session.summary,
                    lines: Self.collapsedSummaryLines,
                    opensExpanded: opensSummaryExpanded,
                )
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(isPresented: $showsVenue) {
            VenueContent()
        }
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteButton(isFavorite: $isFavorite)
            }

            ToolbarItem(placement: .topBarTrailing) {
                shareButton
            }

            // Favourite and Share act on this session. More holds what
            // leaves it, so it sits apart in its own capsule.
            ToolbarSpacer(.fixed, placement: .topBarTrailing)

            ToolbarItem(placement: .topBarTrailing) {
                moreMenu
            }
        }
    }

    /// The session's artwork, sized to the 16 by 9 shape.
    private var artwork: some View {
        MockArtwork(seed: session.id)
            .aspectRatio(16 / 9, contentMode: .fit)
    }

    /// The button that shares this session.
    private var shareButton: some View {
        Button {
        } label: {
            Label {
                Text("Share")
            } icon: {
                Image(icon: .share)
            }
        }
        .tint(.textPrimary)
    }

    /// The menu of actions that lead away from this session.
    private var moreMenu: some View {
        Menu {
            Button {
            } label: {
                Label {
                    Text("Add to Calendar")
                } icon: {
                    Image(icon: .calendar)
                }
            }

            Button {
                showsVenue = true
            } label: {
                Label {
                    Text("Find the room")
                } icon: {
                    Image(icon: .location)
                }
            }
        } label: {
            Label {
                Text("More")
            } icon: {
                Image(icon: .more)
            }
        }
        .tint(.textPrimary)
    }

    /// The heading, with the speakers under it.
    private var headingWithSpeakers: some View {
        VStack(alignment: .leading, spacing: .medium) {
            heading

            speakers
        }
    }

    /// The speakers, one nameplate under another.
    private var speakers: some View {
        VStack(alignment: .leading, spacing: .medium) {
            ForEach(session.speakers) { speaker in
                speakerButton(speaker)
            }
        }
    }

    /// A button that shows the speaker's page, drawn as the speaker's
    /// nameplate.
    ///
    /// The nameplate's style fixes the title's font, so the font sits on the
    /// title's own text, which the style cannot override.
    ///
    /// - Parameter speaker: The speaker the nameplate names.
    private func speakerButton(_ speaker: SamplePerson) -> some View {
        Button {
            showSpeaker(speaker)
        } label: {
            Nameplate {
                Text(speaker.name).font(.subheadline)
            } detail: {
                EmptyView()
            } icon: {
                avatar(for: speaker)
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: Self.minimumTapHeight)
            .contentShape(.rect)
        }
        .buttonStyle(.borderless)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// A speaker's initials on a small disc with an edge.
    ///
    /// - Parameter speaker: The speaker the avatar names.
    private func avatar(for speaker: SamplePerson) -> some View {
        // The initials disc is the row's own color, so it takes an edge to be
        // seen, as the person page's avatar does.
        Avatar(
            url: nil,
            size: .small,
            fallback: .initials(speaker.nameComponents),
        )
        .overlay {
            Circle().strokeBorder(
                .borderPrimary,
                lineWidth: CGFloat(BorderWidth.thin),
            )
        }
    }

    /// What the session is called, and when and where it runs.
    ///
    /// VoiceOver reads it as one heading: the title, then the day, the time,
    /// the room and the badges, in that order.
    private var heading: some View {
        VStack(alignment: .leading, spacing: .small) {
            Text(session.title)
                .font(.title.weight(.bold))
                .foregroundStyle(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            facts

            SessionBadges(session: session)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    /// When and where the session runs, side by side while they fit.
    ///
    /// Each fact is its own text, so a large text size stacks the facts
    /// rather than breaking one across lines, and the row mirrors
    /// right-to-left.
    private var facts: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: .medium) {
                factTexts
            }

            VStack(alignment: .leading, spacing: .xSmall) {
                factTexts
            }
        }
        .font(.subheadline)
        .foregroundStyle(.textSecondary)
    }

    /// The day, the time range and the room, each led by its symbol.
    ///
    /// A no-break space keeps each symbol with its words.
    private var factTexts: some View {
        Group {
            Text("\(Image(icon: .calendar))\u{00A0}\(session.dayLabel)")
            Text("\(Image(icon: .clock))\u{00A0}\(session.time)")
            Text("\(Image(icon: .location))\u{00A0}\(session.room)")
        }
        .fixedSize()
    }
}
