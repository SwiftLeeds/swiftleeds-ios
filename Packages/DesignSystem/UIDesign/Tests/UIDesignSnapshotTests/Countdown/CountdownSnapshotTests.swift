#if os(iOS)
import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite(.snapshots(record: .never)) struct CountdownSnapshotTests {
    /// A countdown style that draws the current color scheme as a word.
    private struct ColorSchemeCountdownStyle: CountdownStyle {
        /// The color scheme the style reads from the environment.
        @Environment(\.colorScheme) private var colorScheme

        /// Creates a view that represents the body of a countdown.
        ///
        /// - Parameter configuration: The properties of the countdown.
        /// - Returns: A view that shows the color scheme as a word.
        func makeBody(configuration: Configuration) -> some View {
            Text(colorScheme == .dark ? "dark" : "light")
        }
    }

    /// A countdown style that draws the label in a fixed frame.
    private struct FixedFrameCountdownStyle: CountdownStyle {
        /// The width of the frame, in points.
        static let width: CGFloat = 160

        /// The height of the frame, in points.
        static let height: CGFloat = 44

        /// Creates a view that represents the body of a countdown.
        ///
        /// - Parameter configuration: The properties of the countdown.
        /// - Returns: A view that shows the label in a bordered frame.
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: Self.width, height: Self.height)
                .border(Color.primary)
        }
    }

    /// The moment every test counts towards.
    private static let start = Date(timeIntervalSinceReferenceDate: 800_000_000)

    /// 09:00 GMT on 29 March 2026, the day UK clocks go forward.
    private static let clockChangeStart = Date(timeIntervalSince1970: 1_774_774_800)

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

    /// Returns a countdown with the clock pinned to a time before the start, in British English.
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

    /// Returns a countdown across a UK clock change, in a time zone.
    ///
    /// It runs 23 hours to 09:00 GMT on 29 March 2026. UK clocks go forward that morning, so the
    /// wording depends on the time zone.
    ///
    /// - Parameter timeZone: The time zone the environment sets.
    /// - Returns: A countdown on the primary surface, with room around it.
    private func countdownAcrossClockChange(in timeZone: TimeZone) -> some View {
        Countdown(to: Self.clockChangeStart)
            .countdownNow(.fixed(Self.clockChangeStart.addingTimeInterval(-23 * 60 * 60)))
            .environment(\.locale, Locale(identifier: "en_GB"))
            .environment(\.timeZone, timeZone)
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

    @Test func whenLoading_shouldDrawSkeleton() {
        assertSnapshots(of: countdown(timeLeft: 12 * 60).redacted(reason: .placeholder))
    }

    @Test func whenTextIsBold_shouldDrawBoldDigits() {
        let light = UITraitCollection {
            $0.userInterfaceStyle = .light
            $0.legibilityWeight = .bold
        }
        // The snapshot helpers have no light-only variant, so this calls assertSnapshot directly.
        assertSnapshot(
            of: countdown(timeLeft: 12 * 60).dynamicTypeSize(.large).fixedSize(),
            as: .image(traits: light),
            named: "light-default",
        )
    }

    @Test func whenEverySettingIsOn_shouldDrawLargeBoldText() {
        let light = UITraitCollection {
            $0.userInterfaceStyle = .light
            $0.legibilityWeight = .bold
            $0.accessibilityContrast = .high
        }
        let view = Badge {
            Countdown(to: Self.start)
                .countdownNow(.fixed(Self.start.addingTimeInterval(-12 * 60)))
        }
        .environment(\.locale, Locale(identifier: "en_GB"))
        .padding(.lg)
        .background(.surface)
        .dynamicTypeSize(.accessibility5)
        .frame(width: rowWidth)
        .fixedSize(horizontal: false, vertical: true)
        assertSnapshot(of: view, as: .image(traits: light), named: "light-accessibility")
    }

    @Test func whenTimeZoneIsLondonAcrossClockChange_shouldDrawInOneDay() throws {
        let london = try #require(TimeZone(identifier: "Europe/London"))
        assertSpecimenSnapshots(of: countdownAcrossClockChange(in: london))
    }

    @Test func whenTimeZoneIsGMTAcrossClockChange_shouldDrawInTwentyThreeHr() {
        assertSpecimenSnapshots(of: countdownAcrossClockChange(in: .gmt))
    }
}
#endif
