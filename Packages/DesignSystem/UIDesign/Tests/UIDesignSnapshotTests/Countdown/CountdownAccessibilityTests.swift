#if os(iOS)
import Foundation
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite
struct CountdownAccessibilityTests {
    /// The moment every test counts towards.
    private static let start = Date(timeIntervalSinceReferenceDate: 800_000_000)

    /// Returns a countdown with the clock pinned before the start.
    ///
    /// - Parameters:
    ///   - timeLeft: How long before the start the pinned clock reads. A negative value
    ///     reads a time after the start.
    ///   - locale: The locale the countdown words the time in. The default is British English.
    /// - Returns: The countdown.
    private func countdown(
        timeLeft: TimeInterval,
        locale: Locale = Locale(identifier: "en_GB"),
    ) -> some View {
        Countdown(to: Self.start)
            .countdownNow(.fixed(Self.start.addingTimeInterval(-timeLeft)))
            .environment(\.locale, locale)
    }

    @Test
    func whenTwelveMinutesRemain_shouldReadWideFormAsFrequentlyUpdatingText() throws {
        let elements = try AccessibilityTree.elements(of: countdown(timeLeft: 12 * 60))
        #expect(elements.count == 1)
        let element = try #require(elements.first)
        #expect(element.label == "in 12 minutes")
        #expect(element.traits == [.staticText, .updatesFrequently])
    }

    @Test
    func whenStartHasPassed_shouldReadNow() throws {
        let elements = try AccessibilityTree.elements(of: countdown(timeLeft: -5 * 60))
        let element = try #require(elements.first)
        #expect(element.label == "now")
        #expect(element.traits == [.staticText, .updatesFrequently])
    }

    @Test
    func whenLocaleIsGerman_shouldReadWideFormInGerman() throws {
        let view = countdown(timeLeft: 12 * 60, locale: Locale(identifier: "de_DE"))
        let element = try #require(try AccessibilityTree.elements(of: view).first)
        #expect(element.label == "in 12 Minuten")
    }

    @Test
    func whenLoading_shouldAddNoElement() throws {
        let view = countdown(timeLeft: 12 * 60).redacted(reason: .placeholder)
        let elements = try AccessibilityTree.elements(of: view)
        #expect(elements.isEmpty)
    }

    @Test
    func whenLoaded_shouldAddOneElement() throws {
        let view = countdown(timeLeft: 12 * 60).redacted(reason: [])
        let elements = try AccessibilityTree.elements(of: view)
        #expect(elements.count == 1)
    }
}
#endif
