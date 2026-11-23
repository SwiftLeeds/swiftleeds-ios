#if os(iOS)
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite
struct BarcodeScanTests {
    /// A style that draws the barcode's content and nothing else.
    private struct ContentOnlyBarcodeStyle: BarcodeStyle {
        @MainActor
        func makeBody(configuration: Configuration) -> some View {
            configuration.content
        }
    }

    /// The made-up text the code carries.
    private static let text = "ti_ExampleTicket0000000000"

    /// The side of the frame the barcode fills, in points.
    private static let side: CGFloat = 220

    /// The number of pixels in one point of the render.
    private static let renderScale: CGFloat = 3

    /// The share of the frame's width that the code's marks must span, from 0 to 1.
    private static let minimumSpan = 0.7

    /// The most alpha, out of 255, that a pixel may have and still count as clear.
    private static let clearTolerance: UInt8 = 8

    /// The most alpha, out of 255, that a pixel may lack and still count as opaque.
    private static let opaqueFloor = 255 - clearTolerance

    /// Returns the pixels of a barcode drawn in the frame, with no style around it.
    ///
    /// - Returns: The pixels of the render, at the render scale.
    /// - Throws: When the code, the render or the pixels cannot be made.
    private func renderedPixels() throws -> RGBAPixels {
        let code = try QRCode(Self.text)
        let view = Barcode(code, label: Text("Ticket QR code"))
            .barcodeStyle(ContentOnlyBarcodeStyle())
            .frame(width: Self.side, height: Self.side)
        let renderer = ImageRenderer(content: view)
        renderer.scale = Self.renderScale
        let image = try #require(renderer.cgImage)
        return try RGBAPixels(of: image)
    }

    @Test
    func whenScaledUp_shouldDrawOnlyOpaqueBlackOrClearPixels() throws {
        let pixels = try renderedPixels()
        let rows = 0..<pixels.height
        let failingCount = (0..<pixels.width).flatMap { column in
            rows.map { pixels.pixel(x: column, y: $0) }
        }.count { pixel in
            let isClear = pixel.alpha <= Self.clearTolerance
            let isOpaque = pixel.alpha >= Self.opaqueFloor
            let isBlack = max(pixel.red, pixel.green, pixel.blue) <= Self.clearTolerance
            return !(isClear || (isOpaque && isBlack))
        }
        #expect(failingCount == 0, "\(failingCount) pixels are neither opaque black nor clear")
    }

    @Test
    func whenFramed_shouldFillFrameWithCode() throws {
        let pixels = try renderedPixels()
        let opaqueColumns = (0..<pixels.width).filter { column in
            (0..<pixels.height).contains { pixels.pixel(x: column, y: $0).alpha > Self.clearTolerance }
        }
        let first = try #require(opaqueColumns.first)
        let last = try #require(opaqueColumns.last)
        let span = Double(last - first + 1) / Double(pixels.width)
        #expect(span > Self.minimumSpan, "The marks span \(span) of the frame's width")
    }
}
#endif
