#if os(iOS)
import SwiftUI
import Testing
import UIKit

@MainActor
@Suite
struct AccessibilityTreeTests {
    @Test
    func whenTextIsHosted_shouldReadOneStaticTextElement() throws {
        let elements = try AccessibilityTree.elements(of: Text("Hello"))
        #expect(elements.count == 1)
        let element = try #require(elements.first)
        #expect(element.label == "Hello")
        #expect(element.traits == .staticText)
    }

    @Test
    func whenButtonIsHosted_shouldReadOneButtonElement() throws {
        let elements = try AccessibilityTree.elements(of: Button("Tap") {})
        #expect(elements.count == 1)
        let element = try #require(elements.first)
        #expect(element.label == "Tap")
        #expect(element.traits == .button)
    }

    @Test
    func whenTextHasAccessibilityValue_shouldReadValue() throws {
        let elements = try AccessibilityTree.elements(of: Text("Hello").accessibilityValue("Three"))
        #expect(elements.count == 1)
        let element = try #require(elements.first)
        #expect(element.value == "Three")
    }
}
#endif
