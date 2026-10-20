import SwiftUI
import UIDesign

/// A view that describes one session and what a person can do about it.
struct SessionDetailScreen: View {
    /// The height of the clear space that follows the content with `-tall 1`.
    private static let tailHeight: CGFloat = 800

    /// The most lines the summary takes until a person asks for the rest.
    private static let collapsedSummaryLines = 4

    /// The widest the About text grows, so its lines stay readable on an iPad.
    private static let readableWidth: CGFloat = 672

    /// How far content sits in from the safe area on an iPhone, which is
    /// Apple's list margin.
    private static let phoneMargin: CGFloat = 16

    /// How far content sits in from the safe area on an iPad, which is
    /// Apple's list margin.
    private static let padMargin: CGFloat = 20

    /// The session this screen describes.
    let session: SampleSession

    /// The action that shows a speaker's page.
    let showSpeaker: (SamplePerson) -> Void

    /// Whether the summary shows in full when the screen appears.
    private let opensSummaryExpanded: Bool

    /// Whether clear space follows the content, so the title can scroll fully
    /// under the bar. The launch argument `-tall 1` turns it on.
    private let addsTail: Bool

    /// How big the page is, or `nil` until it is measured.
    @State private var page: SessionHero.PageSize?

    /// Whether this person favourited the session.
    @State private var isFavorite: Bool

    /// Whether the venue page is pushed, to find the session's room.
    @State private var showsVenue = false

    /// How far the bars cover the list, or `nil` until it first reports.
    @State private var bars: SessionHero.BarInsets?

    /// Creates a screen for one session.
    ///
    /// The launch argument `-tall` adds clear space after the content.
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
        addsTail = UserDefaults.standard.bool(forKey: "tall")
        _isFavorite = State(initialValue: session.isFavorite)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                content

                if addsTail {
                    Color.clear.frame(height: Self.tailHeight)
                }
            }
        }
        .onGeometryChange(for: SessionHero.PageSize.self) { proxy in
            SessionHero.PageSize(
                width: proxy.size.width,
                height: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom,
            )
        } action: { size in
            page = size
        }
        .background(.surface)
        .scrollEdgeEffectStyle(.soft, for: .top)
        .onScrollGeometryChange(for: SessionHero.BarInsets.self) { geometry in
            SessionHero.BarInsets(top: geometry.contentInsets.top, bottom: geometry.contentInsets.bottom)
        } action: { _, newValue in
            bars = newValue
        }
        .navigationDestination(isPresented: $showsVenue) {
            VenueContent()
        }
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(removing: .title)
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
}

// MARK: - Layout

extension SessionDetailScreen {
    /// The page's content, from the top of the page to its foot.
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            SessionHero(session: session, page: page, bars: bars, margin: margin)

            below
        }
    }

    /// The margin on each side of the page, from the safe area to the content.
    private var margin: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? Self.padMargin : Self.phoneMargin
    }

    /// The About text, then the speakers, at the page margin.
    private var below: some View {
        VStack(alignment: .leading, spacing: .xLarge) {
            aboutCard
                .frame(maxWidth: Self.readableWidth, alignment: .leading)

            SpeakerRows(speakers: session.speakers, showSpeaker: showSpeaker)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, margin)
        .padding(.top, .large)
        .padding(.bottom, .large)
    }
}

// MARK: - About

extension SessionDetailScreen {
    /// The summary on a rounded surface, under its heading.
    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: .small) {
            Text("About")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: .medium) {
                ExpandableText(
                    session.summary,
                    lines: Self.collapsedSummaryLines,
                    opensExpanded: opensSummaryExpanded,
                )
            }
            .padding(.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                .secondarySurface,
                in: RoundedRectangle(
                    cornerRadius: CGFloat(CornerRadius.large),
                    style: .continuous,
                ),
            )
        }
    }
}

// MARK: - Toolbar

extension SessionDetailScreen {
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
}
