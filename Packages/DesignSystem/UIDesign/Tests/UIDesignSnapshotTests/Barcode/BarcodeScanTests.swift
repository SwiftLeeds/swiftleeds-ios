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
        return pixels.pixel(at: PixelPosition(column: column * module + halfModule, row: row * module + halfModule))
    }

    /// Counts the pixels that differ from the pixel in the same row on the opposite side.
    ///
    /// - Parameter pixels: The rendered picture.
    /// - Returns: The number of pixels that a left to right mirror would change. Zero means the
    ///   picture is its own mirror.
    private static func mirrorDifferenceCount(of pixels: RGBAPixels) -> Int {
        pixels.columns.flatMap { column in
            pixels.rows.map { PixelPosition(column: column, row: $0) }
        }.count { position in
            let mirror = PixelPosition(column: pixels.width - 1 - position.column, row: position.row)
            return pixels.pixel(at: position) != pixels.pixel(at: mirror)
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
        #expect(topLeft.isOpaqueBlack)
        #expect(topRight.isClear)
        #expect(bottomLeft.isClear)
        #expect(bottomRight.isOpaqueBlack)
    }

    @Test(arguments: BarcodePlateFixture.allCases)
    func whenScaledUp_shouldDrawOnlyOpaqueBlackOrClearPixels(fixture: BarcodePlateFixture) throws {
        let pixels = try renderedPixels(of: fixture)
        let failingCount = pixels.count(columns: pixels.columns, rows: pixels.rows) { pixel in
            !(pixel.isClear || pixel.isOpaqueBlack)
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
        let differingCount = leftToRight.columns.flatMap { column in
            leftToRight.rows.map { PixelPosition(column: column, row: $0) }
        }.count { position in
            leftToRight.pixel(at: position) != rightToLeft.pixel(at: position)
        }
        #expect(differingCount == 0, "\(differingCount) pixels differ between the two directions")
    }

    @Test(arguments: BarcodePlateFixture.allCases)
    func whenFramed_shouldFillFrameWithCode(fixture: BarcodePlateFixture) throws {
        let pixels = try renderedPixels(of: fixture)
        let opaqueColumns = pixels.columns.filter { column in
            !pixels.isClear(columns: column..<(column + 1), rows: pixels.rows)
        }
        let first = try #require(opaqueColumns.first)
        let last = try #require(opaqueColumns.last)
        let span = Double(last - first + 1) / Double(pixels.width)
        #expect(span > Self.minimumSpan, "The marks span \(span) of the frame's width")
    }
}
#endif
