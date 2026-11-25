#if os(iOS)
import SwiftUI
import Testing
import UIDesign
import UIDesignTestSupport

@MainActor
@Suite
struct BarcodeScanTests {
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

    /// The side of the frame the barcode fills, in points.
    private static let side: CGFloat = 220

    /// The number of pixels in one point of the render.
    private static let renderScale: CGFloat = 3

    /// The share of the frame's width the code's marks must span.
    ///
    /// It runs from 0 to 1.
    private static let minimumSpan = 0.7

    /// The most alpha, out of 255, a pixel may have and count as clear.
    private static let clearTolerance: UInt8 = 8

    /// The brightest color channel, out of 255, that still counts as black.
    private static let blackCeiling: UInt8 = 8

    /// The least alpha, out of 255, that a pixel must have to count as opaque.
    private static let opaqueFloor = 255 - clearTolerance

    /// Returns the pixels of a barcode drawn at its typical frame, with no style around it.
    ///
    /// - Parameters:
    ///   - fixture: The kind of code to draw.
    ///   - layoutDirection: The layout direction of the environment. The default is left to right.
    /// - Returns: The pixels of the render, at the render scale.
    /// - Throws: When the code, the render or the pixels cannot be made.
    private func renderedPixels(
        of fixture: BarcodePlateFixture,
        layoutDirection: LayoutDirection = .leftToRight,
    ) throws -> RGBAPixels {
        let code = try fixture.makeContent()
        let view = Barcode(code, label: Text("Code"))
            .barcodeStyle(ContentOnlyBarcodeStyle())
            .frame(width: fixture.frameSize.width, height: fixture.frameSize.height)
            .environment(\.layoutDirection, layoutDirection)
        let renderer = ImageRenderer(content: view)
        renderer.scale = Self.renderScale
        let image = try #require(renderer.cgImage)
        return try RGBAPixels(of: image)
    }

    /// Returns the pixel at the center of one module of a rendered picture.
    ///
    /// - Parameters:
    ///   - pixels: The rendered picture, split into equal modules.
    ///   - column: The module's column, from the left.
    ///   - row: The module's row, from the top.
    /// - Returns: The pixel at the module's center.
    private static func centerPixel(of pixels: RGBAPixels, column: Int, row: Int) -> RGBAPixels.Pixel {
        let module = pixels.width / CheckerBarcodeContent.modulesAcross
        let halfModule = module / 2
        return pixels.pixel(x: column * module + halfModule, y: row * module + halfModule)
    }

    /// Counts the pixels that differ from the pixel in the same row on the opposite side.
    ///
    /// - Parameter pixels: The rendered picture.
    /// - Returns: The number of pixels that a left to right mirror would change. Zero means the
    ///   picture is its own mirror.
    private static func mirrorDifferenceCount(of pixels: RGBAPixels) -> Int {
        let rows = 0..<pixels.height
        return (0..<pixels.width).flatMap { column in
            rows.map { (column, $0) }
        }.count { column, row in
            pixels.pixel(x: column, y: row) != pixels.pixel(x: pixels.width - 1 - column, y: row)
        }
    }

    @Test
    func whenContentIsCustom_shouldDrawItsPixels() throws {
        let view = Barcode(try CheckerBarcodeContent(), label: Text("Check-in QR code"))
            .barcodeStyle(ContentOnlyBarcodeStyle())
            .frame(width: Self.side, height: Self.side)
        let renderer = ImageRenderer(content: view)
        renderer.scale = Self.renderScale
        let pixels = try RGBAPixels(of: try #require(renderer.cgImage))
        let topLeft = Self.centerPixel(of: pixels, column: 0, row: 0)
        let topRight = Self.centerPixel(of: pixels, column: 1, row: 0)
        let bottomLeft = Self.centerPixel(of: pixels, column: 0, row: 1)
        let bottomRight = Self.centerPixel(of: pixels, column: 1, row: 1)
        #expect(topLeft.alpha >= Self.opaqueFloor)
        #expect(max(topLeft.red, topLeft.green, topLeft.blue) <= Self.blackCeiling)
        #expect(topRight.alpha <= Self.clearTolerance)
        #expect(bottomLeft.alpha <= Self.clearTolerance)
        #expect(bottomRight.alpha >= Self.opaqueFloor)
        #expect(max(bottomRight.red, bottomRight.green, bottomRight.blue) <= Self.blackCeiling)
    }

    @Test(arguments: BarcodePlateFixture.allCases)
    func whenScaledUp_shouldDrawOnlyOpaqueBlackOrClearPixels(fixture: BarcodePlateFixture) throws {
        let pixels = try renderedPixels(of: fixture)
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

    @Test(arguments: BarcodePlateFixture.allCases)
    func whenLayoutIsRightToLeft_shouldDrawSamePixelsAsLeftToRight(fixture: BarcodePlateFixture) throws {
        let leftToRight = try renderedPixels(of: fixture, layoutDirection: .leftToRight)
        let rightToLeft = try renderedPixels(of: fixture, layoutDirection: .rightToLeft)
        let asymmetry = Self.mirrorDifferenceCount(of: leftToRight)
        try #require(asymmetry > 0, "The picture is its own mirror, so a mirrored render would look the same")
        #expect(leftToRight.width == rightToLeft.width)
        #expect(leftToRight.height == rightToLeft.height)
        let rows = 0..<leftToRight.height
        let differingCount = (0..<leftToRight.width).flatMap { column in
            rows.map { (column, $0) }
        }.count { column, row in
            leftToRight.pixel(x: column, y: row) != rightToLeft.pixel(x: column, y: row)
        }
        #expect(differingCount == 0, "\(differingCount) pixels differ between the two directions")
    }

    @Test(arguments: BarcodePlateFixture.allCases)
    func whenFramed_shouldFillFrameWithCode(fixture: BarcodePlateFixture) throws {
        let pixels = try renderedPixels(of: fixture)
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
