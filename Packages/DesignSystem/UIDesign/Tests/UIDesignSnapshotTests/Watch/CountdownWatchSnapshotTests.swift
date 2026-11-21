#if os(watchOS)
import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite(.snapshots(record: .never)) struct CountdownWatchSnapshotTests {
    /// British English, the language the snapshot scheme pins.
    private static let britishEnglish = Locale(identifier: "en_GB")

    /// Arabic, which reads right to left.
    private static let arabic = Locale(identifier: "ar")

    /// The moment every test counts towards.
    private static let start = Date(timeIntervalSinceReferenceDate: 800_000_000)

    /// Returns a countdown with the clock pinned to a time before the start.
    ///
    /// - Parameters:
    ///   - timeLeft: How long before the start the pinned clock reads.
    ///   - locale: The locale the countdown words the time in.
    /// - Returns: The countdown.
    private func countdown(timeLeft: TimeInterval, locale: Locale = britishEnglish) -> some View {
        Countdown(to: Self.start)
            .countdownNow(.fixed(Self.start.addingTimeInterval(-timeLeft)))
            .environment(\.locale, locale)
            .environment(\.layoutDirection, locale == Self.arabic ? .rightToLeft : .leftToRight)
    }

    /// Returns the PNG bytes of a countdown drawn by `ImageRenderer`.
    ///
    /// - Parameters:
    ///   - timeLeft: How long before the start the pinned clock reads.
    ///   - isLuminanceReduced: Whether the screen is dimmed, as in Always On.
    /// - Returns: The PNG data, or `nil` when the view draws no image.
    private func png(timeLeft: TimeInterval, isLuminanceReduced: Bool) -> Data? {
        let view = countdown(timeLeft: timeLeft)
            .environment(\.isLuminanceReduced, isLuminanceReduced)
        return ImageRenderer(content: view).uiImage?.pngData()
    }

    @Test func whenTwelveMinutesRemain_shouldFitTheScreen() {
        assertSnapshots(of: countdown(timeLeft: 12 * 60))
    }

    @Test func whenTwelveDaysRemain_shouldFitTheScreen() {
        assertSnapshots(of: countdown(timeLeft: 12 * 24 * 60 * 60))
    }

    @Test func whenReadingNow_shouldFitTheScreen() {
        assertSnapshots(of: countdown(timeLeft: 30))
    }

    @Test func whenLocaleIsArabic_shouldFitOneLineWithoutCutting() {
        assertSnapshots(of: countdown(timeLeft: 12 * 60, locale: Self.arabic))
    }

    @Test func whenLuminanceIsReduced_shouldRenderSamePixels() throws {
        let normal = try #require(png(timeLeft: 12 * 60, isLuminanceReduced: false))
        let dimmed = try #require(png(timeLeft: 12 * 60, isLuminanceReduced: true))
        #expect(normal == dimmed)
    }

    @Test func whenTimeDiffers_shouldRenderDifferentPixels() throws {
        let twelve = try #require(png(timeLeft: 12 * 60, isLuminanceReduced: false))
        let nine = try #require(png(timeLeft: 9 * 60, isLuminanceReduced: false))
        #expect(twelve != nine)
    }
}
#endif
