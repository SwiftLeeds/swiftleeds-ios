import SwiftUI
import UIDesign

/// A view that summarizes a talk a person is giving, with its artwork.
struct TalkRow: View {
    /// The session this row describes.
    let session: SampleSession

    /// How wide and tall the artwork's square is.
    ///
    /// The artwork identifies the talk, so it is content rather than
    /// decoration and grows with the text beside it.
    @ScaledMetric(relativeTo: .headline) private var artworkSide: CGFloat = 56

    var body: some View {
        ReflowingStack {
            MockArtwork(seed: session.id, cornerRadius: .small)
                .frame(width: artworkSide, height: artworkSide)

            VStack(alignment: .leading, spacing: .xSmall) {
                Text(session.title)
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(session.dayLabel) • \(session.time) • \(session.room)")
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                SessionBadges(session: session)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
        }
    }
}
