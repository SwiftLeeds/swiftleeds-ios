import SwiftUI
import UIDesign

/// A view that summarizes one session in the schedule.
struct SessionRow: View {
    /// The session this row describes.
    let session: SampleSession

    /// Whether the row leads with the session's picture.
    var showsArtwork = false

    /// How wide and tall the leading picture is.
    private static let artworkSide: CGFloat = 64

    var body: some View {
        HStack(alignment: .top, spacing: .medium) {
            if showsArtwork {
                MockArtwork(seed: session.id, cornerRadius: .medium)
                    .frame(width: Self.artworkSide, height: Self.artworkSide)
            }

            details
        }
    }

    /// Everything the row says, in the order it reads.
    private var details: some View {
        VStack(alignment: .leading, spacing: .small) {
            HStack(spacing: .small) {
                Text("\(session.time) • \(session.room)")
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)

                if let startsIn = session.startsIn {
                    MockBadge(text: startsIn, tint: .success)
                }

                Spacer(minLength: 0)

                if session.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.footnote)
                        .foregroundStyle(.warning)
                        .accessibilityLabel("Saved")
                }
            }

            Text(session.title)
                .font(.headline)
                .foregroundStyle(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: .small) {
                Text(session.speaker)
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)

                Spacer(minLength: 0)

                if let kind = session.kind {
                    MockNeutralBadge(text: kind)
                }
            }
        }
    }
}
