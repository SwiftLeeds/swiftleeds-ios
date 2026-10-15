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

                Text("\(dayLabel) • \(session.time) • \(session.room)")
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                badges
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
        }
    }

    /// Names the day relative to now: "Today", "Tomorrow", or else the weekday
    /// and date.
    private var dayLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(session.start) || calendar.isDateInTomorrow(session.start) {
            let relative = session.start.formatted(
                Date.RelativeFormatStyle(
                    allowedFields: [.day],
                    presentation: .named,
                    unitsStyle: .wide,
                )
            )
            return relative.prefix(1).uppercased() + relative.dropFirst()
        }
        return session.start.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
    }

    /// When the talk starts and what kind of talk it is, if either is known.
    private var badges: some View {
        HStack(spacing: .small) {
            if let startsIn = session.startsIn {
                MockBadge(text: startsIn, tint: .success)
            }

            if let kind = session.kind {
                MockNeutralBadge(text: kind)
            }
        }
    }
}
