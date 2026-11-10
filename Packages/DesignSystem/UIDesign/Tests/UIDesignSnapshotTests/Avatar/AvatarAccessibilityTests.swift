#if os(iOS)
import Foundation
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite
struct AvatarAccessibilityTests {
    @Test
    func whenAvatarHasNoStatus_shouldAddNoElement() throws {
        let elements = try AccessibilityTree.elements(
            of: HStack {
                Avatar(url: nil)
                Text("Ada Archer")
            }
        )
        #expect(elements.count == 1)
        let element = try #require(elements.first)
        #expect(element.label == "Ada Archer")
        #expect(element.traits == .staticText)
    }

    @Test
    func whenAvatarHasInitialsAndNoStatus_shouldAddNoElement() throws {
        let name = PersonNameComponents(givenName: "Ada", familyName: "Archer")
        let elements = try AccessibilityTree.elements(
            of: HStack {
                Avatar(url: nil, fallback: .initials(name))
                Text("Ada Archer")
            }
        )
        #expect(elements.count == 1)
        let element = try #require(elements.first)
        #expect(element.label == "Ada Archer")
        #expect(element.traits == .staticText)
    }
}
#endif
