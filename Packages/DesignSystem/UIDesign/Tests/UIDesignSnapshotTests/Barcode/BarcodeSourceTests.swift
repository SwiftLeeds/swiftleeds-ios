#if os(iOS)
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite
struct BarcodeSourceTests {
    /// A style that draws the barcode's content and nothing else.
    private struct ContentOnlyBarcodeStyle: BarcodeStyle {
        /// Creates a view that represents the body of a barcode.
        ///
        /// - Parameter configuration: The properties of the barcode.
        /// - Returns: A view that represents the body of a barcode.
        @MainActor
        func makeBody(configuration: Configuration) -> some View {
            configuration.content
        }
    }

    /// The label the caller gives the barcode.
    private static let callerLabel = "Membership QR code"

    /// The side of the frame the barcode fills, in points.
    private static let side: CGFloat = 220

    /// The number of pixels in one point of the render.
    private static let renderScale: CGFloat = 2

    /// The most alpha, out of 255, a pixel may have and count as clear.
    private static let clearTolerance: UInt8 = 8

    /// The brightest color channel, out of 255, that still counts as black.
    private static let blackCeiling: UInt8 = 8

    /// The least alpha, out of 255, that a pixel must have to count as opaque.
    private static let opaqueFloor = 255 - clearTolerance

    @Test
    func whenImageIsSupplied_shouldExposeOneImageElementWithCallerLabel() throws {
        let sut = Barcode(try CheckerBarcodeContent().cgImage, label: Text(Self.callerLabel))
        let elements = try AccessibilityTree.elements(of: sut)
        let element = try #require(elements.first)
        #expect(elements.count == 1)
        #expect(element.label == Self.callerLabel)
        #expect(element.traits.contains(.image))
        #expect(element.value == nil)
    }

    @Test
    func whenImageIsSupplied_shouldDrawOnlyBlackOrClearPixels() throws {
        let view = Barcode(try CheckerBarcodeContent().cgImage, label: Text(Self.callerLabel))
            .barcodeStyle(ContentOnlyBarcodeStyle())
            .frame(width: Self.side, height: Self.side)
        let renderer = ImageRenderer(content: view)
        renderer.scale = Self.renderScale
        let pixels = try RGBAPixels(of: try #require(renderer.cgImage))
        let rows = 0..<pixels.height
        let failingCount = (0..<pixels.width).flatMap { column in
            rows.map { pixels.pixel(x: column, y: $0) }
        }.count { pixel in
            let isClear = pixel.alpha <= Self.clearTolerance
            let isOpaque = pixel.alpha >= Self.opaqueFloor
            let isBlack = max(pixel.red, pixel.green, pixel.blue) <= Self.blackCeiling
            return !(isClear || (isOpaque && isBlack))
        }
        #expect(failingCount == 0, "\(failingCount) pixels are neither opaque black nor clear")
    }
}
#endif
