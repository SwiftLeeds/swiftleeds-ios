#if os(iOS)
import SwiftUI
import Testing
import UIDesign
import UIDesignTestSupport
import UIKit

@MainActor
@Suite
struct BarcodeAccessibilityTests {
    /// The label the caller gives the barcode.
    private static let label = "Ticket QR code"

    /// The label the caller gives a barcode of custom content.
    private static let customLabel = "Check-in QR code"

    /// The text the code carries, made up.
    private static let text = BarcodeFixture.qrCode.text

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

    @Test
    func whenContentIsCustom_shouldExposeOneImageElementWithLabel() throws {
        let content = try CheckerBarcodeContent()
        let sut = Barcode(content, label: Text(Self.customLabel))
        let elements = try AccessibilityTree.elements(of: sut)
        let element = try #require(elements.first)
        #expect(elements.count == 1)
        #expect(element.label == Self.customLabel)
        #expect(element.traits.contains(.image))
        #expect(element.value == nil)
    }

    @Test
    func whenRedacted_shouldExposeNoElement() throws {
        let code = try QRCode(Self.text)
        let sut = Barcode(code, label: Text(Self.label))
            .redacted(reason: .placeholder)
        let elements = try AccessibilityTree.elements(of: sut)
        #expect(elements.isEmpty, "\(elements.count) elements are exposed")
    }
}
#endif
