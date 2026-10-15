import SwiftUI
import UIDesign

/// A view that summarizes one session in the schedule.
struct SessionRow: View {
    /// The session this row describes.
    let session: SampleSession

    var body: some View {
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
                Text(session.speakers.map(\.name).joined(separator: ", "))
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
