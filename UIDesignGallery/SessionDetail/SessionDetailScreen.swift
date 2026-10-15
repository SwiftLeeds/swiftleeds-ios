import SwiftUI
import UIDesign

/// A view that describes one session and what a person can do about it.
struct SessionDetailScreen: View {
    /// The session this screen describes.
    let session: SampleSession

    var body: some View {
        List {
            // The artwork, the title and the action are the screen's subject
            // rather than a list of facts about it, so they sit on the page
            // with no card and no separators between them.
            Section {
                MockArtwork(seed: session.id)
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .listRowInsets(EdgeInsets())

                heading

                favoriteAction
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
        // The title is long enough that the bar would truncate it to one line,
        // so the content carries it and the bar stays bare.
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Label("Calendar", systemImage: "calendar.badge.plus")
                }
                .tint(.textPrimary)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .tint(.textPrimary)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Label("More", systemImage: "ellipsis")
                }
                .tint(.textPrimary)
            }
        }
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

    /// The one action this screen is for, at the screen's highest contrast.
    ///
    /// It is the screen's only filled control, which is what marks it as the
    /// one the screen is for.
    private var favoriteAction: some View {
        Button {
        } label: {
            Label("Favourite", systemImage: "star")
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(.brandPrimary)
    }
}
