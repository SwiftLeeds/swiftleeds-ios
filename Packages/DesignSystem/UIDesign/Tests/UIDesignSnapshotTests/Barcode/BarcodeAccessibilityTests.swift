#if os(iOS)
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite
struct BarcodeAccessibilityTests {
    /// The label the caller gives the barcode.
    private static let label = "Ticket QR code"

    /// The text the code carries, made up.
    private static let text = "ti_ExampleTicket0000000000"

    @Test
    func whenCodeIsDrawn_shouldExposeOneImageElementWithLabel() throws {
        let code = try QRCode(Self.text)
        let sut = Barcode(code, label: Text(Self.label))
        let elements = try AccessibilityTree.elements(of: sut)
        let element = try #require(elements.first)
        #expect(elements.count == 1)
        #expect(element.label == Self.label)
        #expect(element.traits.contains(.image))
        #expect(element.value == nil)
    }
}
#endif
