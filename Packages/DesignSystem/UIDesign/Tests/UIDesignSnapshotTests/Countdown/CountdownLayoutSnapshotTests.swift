#if os(iOS)
import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite(.snapshots(record: .never)) struct CountdownLayoutSnapshotTests {
    /// British English, the language the snapshot scheme pins.
    private static let britishEnglish = Locale(identifier: "en_GB")

    /// German, the language with the longest abbreviated words.
    private static let german = Locale(identifier: "de_DE")

    /// Arabic, which reads right to left.
    private static let arabic = Locale(identifier: "ar")

    /// The moment every test counts towards.
    private static let start = Date(timeIntervalSinceReferenceDate: 800_000_000)

    /// How long before the start each wording reads: days, a day, hours, minutes and "now".
    private static let wordings: [TimeInterval] = [
        40 * 24 * 60 * 60, 12 * 24 * 60 * 60, 27 * 60 * 60, 119 * 60, 12 * 60, 9 * 60, 80, 30,
    ]

    /// The traits of a light screen.
    private static let light = UITraitCollection { $0.userInterfaceStyle = .light }

    /// Returns a countdown with the clock pinned to a time before the start.
    ///
    /// - Parameters:
    ///   - timeLeft: How long before the start the pinned clock reads.
    ///   - locale: The locale the countdown words the time in.
    /// - Returns: The countdown.
    private func countdown(timeLeft: TimeInterval, locale: Locale) -> some View {
        Countdown(to: Self.start)
            .countdownNow(.fixed(Self.start.addingTimeInterval(-timeLeft)))
            .environment(\.locale, locale)
            .environment(\.layoutDirection, locale == Self.arabic ? .rightToLeft : .leftToRight)
    }

    /// Returns a badge for each wording, stacked on the primary surface.
    ///
    /// - Parameter locale: The locale the countdowns word the time in.
    /// - Returns: The badges.
    private func badges(locale: Locale) -> some View {
        VStack(alignment: .leading, spacing: .md) {
            ForEach(Self.wordings, id: \.self) { timeLeft in
                Badge { countdown(timeLeft: timeLeft, locale: locale) }
            }
        }
        .padding(.lg)
        .background(.surface)
    }

    /// Returns a view at the largest text size, as wide as a narrow list row.
    ///
    /// The width is that of a list row on the narrowest phone.
    ///
    /// - Parameter view: The view to size.
    /// - Returns: The view at the largest accessibility text size.
    private func atLargestTextSize(_ view: some View) -> some View {
        view
            .dynamicTypeSize(.accessibility5)
            .frame(width: rowWidth)
            .fixedSize(horizontal: false, vertical: true)
    }

    @Test func whenTrailingInListRows_shouldKeepWidthWithinSameDigitCount() {
        let list = List {
            ForEach([18, 12, 11, 10, 9], id: \.self) { minutes in
                HStack {
                    Text("Talk \(minutes)")
                    Spacer()
                    countdown(timeLeft: TimeInterval(minutes * 60), locale: Self.britishEnglish)
                }
            }
        }
        .frame(width: narrowestPhoneWidth, height: 300)
        assertSpecimenSnapshots(of: list)
    }

    @Test func whenInBadgeAtLargestTextSize_shouldShowWholeText() {
        for (name, locale) in [("en-GB", Self.britishEnglish), ("de-DE", Self.german)] {
            assertSnapshot(
                of: atLargestTextSize(badges(locale: locale)),
                as: .image(traits: Self.light),
                named: "\(name)-light-accessibility",
            )
        }
    }

    @Test func whenArabicOneMinuteInBadgeAtLargestTextSize_shouldCutAfterMinuteWord() {
        let view = Badge { countdown(timeLeft: 80, locale: Self.arabic) }
            .padding(.lg)
            .background(.surface)
        assertSnapshot(
            of: atLargestTextSize(view),
            as: .image(traits: Self.light),
            named: "light-accessibility",
        )
    }

    @Test func whenInBadgeWithIncreasedContrast_shouldDrawIncreasedContrastColors() {
        let view = Badge { countdown(timeLeft: 12 * 60, locale: Self.britishEnglish) }
            .padding(.lg)
            .background(.surface)
        assertContrastSnapshots(of: view)
    }

    @Test func whenCompact_shouldFitBadgeAtDefaultSizeAndCutItAtLargestTextSize() {
        let view = Badge { countdown(timeLeft: 12 * 60, locale: Self.britishEnglish) }
            .padding(.lg)
            .background(.surface)
        assertCompactSnapshots(of: view)
    }

    @Test func whenLocaleIsArabic_shouldDrawArabicRightToLeft() {
        let view = countdown(timeLeft: 12 * 60, locale: Self.arabic)
            .frame(width: narrowestPhoneWidth, alignment: .leading)
            .padding(.lg)
            .background(.surface)
            .environment(\.layoutDirection, .rightToLeft)
        assertSpecimenSnapshots(of: view)
    }
}
#endif
