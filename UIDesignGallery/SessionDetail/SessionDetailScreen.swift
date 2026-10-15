import SwiftUI
import UIDesign

/// A view that describes one session and what a person can do about it.
struct SessionDetailScreen: View {
    /// The session this screen describes.
    let session: SampleSession

    /// Whether this person favourited the session.
    @State private var isFavorite: Bool

    /// Whether the venue page is pushed, to find the session's room.
    @State private var showsVenue = false

    /// Creates a screen for one session.
    ///
    /// - Parameter session: The session this screen describes.
    init(session: SampleSession) {
        self.session = session
        _isFavorite = State(initialValue: session.isFavorite)
    }

    var body: some View {
        List {
            // The artwork and the title are the screen's subject rather than
            // a list of facts about it, so they sit on the page with no card
            // and no separators between them.
            Section {
                MockArtwork(seed: session.id)
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .listRowInsets(EdgeInsets())

                heading
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section("About") {
                Text(session.summary)
            }

            Section(session.speakers.count == 1 ? "Speaker" : "Speakers") {
                ForEach(session.speakers) { speaker in
                    NavigationLink(value: speaker) {
                        Nameplate(speaker.name, detail: speaker.detail) {
                            Avatar(
                                url: nil,
                                size: .medium,
                                fallback: .initials(speaker.nameComponents),
                            )
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(isPresented: $showsVenue) {
            VenueContent()
        }
        // The title is long enough that the bar would truncate it to one line,
        // so the content carries it and the bar stays bare.
        .navigationTitle("")
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

    /// What the session is called, and when and where it runs.
    private var heading: some View {
        VStack(alignment: .leading, spacing: .small) {
            Text(session.title)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.textPrimary)

            HStack(spacing: .medium) {
                Label(session.time, systemImage: "clock")
                Label(session.room, systemImage: "mappin.and.ellipse")
            }
            .font(.subheadline)
            .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
