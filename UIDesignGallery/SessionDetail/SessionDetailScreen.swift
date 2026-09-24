import SwiftUI
import UIDesign

/// A view that describes one session and what a person can do about it.
struct SessionDetailScreen: View {
    /// The session this screen describes.
    let session: SampleSession

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .large) {
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

                favoriteAction

                section("About") {
                    Text(session.summary)
                        .font(.body)
                        .foregroundStyle(.textSecondary)
                }

                section("Speaker") {
                    Nameplate(session.speaker, detail: session.speakerDetail) {
                        Avatar(
                            url: nil,
                            size: .medium,
                            fallback: .initials(session.speakerName)
                        )
                    }
                }
            }
            .padding(.horizontal, .large)
            .padding(.bottom, .large)
        }
        .background { AmbientBackground() }
        // The title is long enough that the bar would truncate it to one line,
        // so the content carries it and the bar stays bare.
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {} label: {
                    Label("Calendar", systemImage: "calendar.badge.plus")
                }
                .tint(.textPrimary)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {} label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .tint(.textPrimary)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {} label: {
                    Label("More", systemImage: "ellipsis")
                }
                .tint(.textPrimary)
            }
        }
    }

    /// The one action this screen is for, at the screen's highest contrast.
    private var favoriteAction: some View {
        Button {} label: {
            Label("Favourite", systemImage: "star")
                .font(.headline)
                .foregroundStyle(.surface)
                .frame(maxWidth: .infinity)
                .padding(.vertical, .medium)
                .background(
                    .textPrimary,
                    in: .rect(cornerRadius: CGFloat(CornerRadius.large), style: .continuous)
                )
        }
        .buttonStyle(.plain)
    }

    /// Returns a heading with its content grouped under it.
    ///
    /// - Parameters:
    ///   - title: The heading's text.
    ///   - content: A content builder that creates what sits under the heading.
    private func section(
        _ title: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: .small) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.textPrimary)

            content().contentGroup()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
