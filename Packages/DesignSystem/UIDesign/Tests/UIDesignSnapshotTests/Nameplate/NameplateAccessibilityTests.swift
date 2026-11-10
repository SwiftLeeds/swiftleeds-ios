#if os(iOS)
import Testing
import UIDesign
import UIKit

@MainActor
@Suite
struct NameplateAccessibilityTests {
    @Test
    func whenNameplateHasDetailAndStatus_shouldReadOneElementWithEveryLine() throws {
        let elements = try AccessibilityTree.elements(
            of: Nameplate("Ada Archer", detail: "Northern Software") {
                Avatar(url: nil, status: AvatarStatus("Checked in"))
            }
        )
        #expect(elements.count == 1)
        let element = try #require(elements.first)
        #expect(element.label == "Ada Archer, Northern Software, Checked in")
        #expect(element.traits == .staticText)
    }
}
#endif
