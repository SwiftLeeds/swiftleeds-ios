#if os(iOS)
import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct CountdownSnapshotTests {
    /// A countdown style that draws the color scheme it reads from the environment as a word.
    private struct ColorSchemeCountdownStyle: CountdownStyle {
        /// The color scheme the style reads from the environment.
        @Environment(\.colorScheme) private var colorScheme

        func makeBody(configuration: Configuration) -> some View {
            Text(colorScheme == .dark ? "dark" : "light")
        }
    }

    /// A countdown style that draws the label in a fixed frame, so a test can tell it from the default.
    private struct FixedFrameCountdownStyle: CountdownStyle {
        /// The width of the frame, in points.
        static let width: CGFloat = 160

        /// The height of the frame, in points.
        static let height: CGFloat = 44

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: Self.width, height: Self.height)
                .border(Color.primary)
        }
    }

    /// The moment every test counts towards.
    private static let start = Date(timeIntervalSinceReferenceDate: 800_000_000)

    /// Countdowns for each number of minutes left, trailing-aligned, each on its own fill.
    ///
    /// The fill shows the width of each row.
    private var changingNumbers: some View {
        VStack(alignment: .trailing, spacing: .xs) {
            ForEach([18, 12, 11, 10, 9], id: \.self) { minutes in
                Countdown(to: Self.start)
                    .countdownNow(.fixed(Self.start.addingTimeInterval(-TimeInterval(minutes * 60))))
                    .background(.secondarySurface)
            }
        }
        .environment(\.locale, Locale(identifier: "en_GB"))
        .padding(.lg)
        .background(.surface)
    }

    /// The countdown in British English with the clock pinned to a time before the start.
    ///
    /// - Parameter timeLeft: How long before the start the pinned clock reads.
    /// - Returns: A countdown on the primary surface, with room around it.
    private func countdown(timeLeft: TimeInterval) -> some View {
        Countdown(to: Self.start)
            .countdownNow(.fixed(Self.start.addingTimeInterval(-timeLeft)))
            .environment(\.locale, Locale(identifier: "en_GB"))
            .padding(.lg)
            .background(.surface)
    }

    @Test func whenTwelveMinutesRemain_shouldDrawInTwelveMin() {
        assertSnapshots(of: countdown(timeLeft: 12 * 60))
    }

    @Test func whenNumberChanges_shouldKeepWidthWithinSameDigitCount() {
        assertSnapshots(of: changingNumbers)
    }

    @Test func whenStyleReadsColorScheme_shouldSeeTheCurrentScheme() {
        let view = Countdown(to: Self.start)
            .countdownNow(.fixed(Self.start.addingTimeInterval(-12 * 60)))
            .countdownStyle(ColorSchemeCountdownStyle())
            .padding(.lg)
            .background(.surface)
        assertSpecimenSnapshots(of: view)
    }

    @Test func whenStyleIsSetOnParent_shouldReachCountdown() {
        let view = VStack {
            Countdown(to: Self.start)
                .countdownNow(.fixed(Self.start.addingTimeInterval(-12 * 60)))
        }
        .environment(\.locale, Locale(identifier: "en_GB"))
        .countdownStyle(FixedFrameCountdownStyle())
        .padding(.lg)
        .background(.surface)
        assertSpecimenSnapshots(of: view)
    }
}
#endif
