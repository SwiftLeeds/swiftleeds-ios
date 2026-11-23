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

    @Test
    func whenFramed_shouldFillFrameWithCode() throws {
        let code = try QRCode(Self.text)
        let view = Barcode(code, label: Text("Ticket QR code"))
            .barcodeStyle(ContentOnlyBarcodeStyle())
            .frame(width: Self.side, height: Self.side)
        let renderer = ImageRenderer(content: view)
        renderer.scale = Self.renderScale
        let image = try #require(renderer.cgImage)
        let pixels = try RGBAPixels(of: image)
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
