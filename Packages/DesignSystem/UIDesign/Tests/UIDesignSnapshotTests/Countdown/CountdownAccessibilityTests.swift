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

    /// A countdown in British English with the clock pinned to a time before the start.
    ///
    /// - Parameter timeLeft: How long before the start the pinned clock reads. A negative value
    ///   reads a time after the start.
    /// - Returns: The countdown.
    private func countdown(timeLeft: TimeInterval) -> some View {
        Countdown(to: Self.start)
            .countdownNow(.fixed(Self.start.addingTimeInterval(-timeLeft)))
            .environment(\.locale, Locale(identifier: "en_GB"))
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
