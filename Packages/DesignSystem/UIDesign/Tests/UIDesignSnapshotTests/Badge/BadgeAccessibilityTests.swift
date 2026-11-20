#if os(iOS)
import SFSafeSymbols
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite
struct BadgeAccessibilityTests {
    @Test
    func whenBadgeHasTitleOnly_shouldReadTitleAsOneStaticTextElement() throws {
        let elements = try AccessibilityTree.elements(of: Badge("Workshop"))
        #expect(elements.count == 1)
        let element = try #require(elements.first)
        #expect(element.label == "Workshop")
        #expect(element.traits == .staticText)
    }

    @Test(arguments: [BadgeStatus.success, .warning, .error, .info])
    func whenBadgeHasStatus_shouldReadTitleAsOneStaticTextElement(status: BadgeStatus) throws {
        let elements = try AccessibilityTree.elements(of: Badge("Workshop", status: status))
        #expect(elements.count == 1)
        let element = try #require(elements.first)
        #expect(element.label == "Workshop")
        #expect(element.traits == .staticText)
    }

    @Test
    func whenBadgeHasIcon_shouldReadTitleAsOneStaticTextElement() throws {
        let elements = try AccessibilityTree.elements(of: Badge("Workshop", icon: Icon(.hammerFill)))
        #expect(elements.count == 1)
        let element = try #require(elements.first)
        #expect(element.label == "Workshop")
        #expect(element.traits == .staticText)
    }

    @Test
    func whenBadgeTitleIsLong_shouldReadWholeTitleAsOneStaticTextElement() throws {
        let title = "Fully booked, join the waiting list"
        let view = Badge(title).frame(width: 160)
        let elements = try AccessibilityTree.elements(of: view)
        #expect(elements.count == 1)
        let element = try #require(elements.first)
        #expect(element.label == title)
        #expect(element.traits == .staticText)
    }
}
#endif
