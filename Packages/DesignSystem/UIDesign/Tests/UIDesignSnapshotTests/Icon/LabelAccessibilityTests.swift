#if os(iOS)
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite
struct LabelAccessibilityTests {
    @Test
    func whenLabelHasTitleAndIcon_shouldReadTitleAsOneStaticTextElement() throws {
        let elements = try AccessibilityTree.elements(of: Label("Clock", icon: .clock))
        #expect(elements.count == 1)
        let element = try #require(elements.first)
        #expect(element.label == "Clock")
        #expect(element.traits == .staticText)
    }
}
#endif
