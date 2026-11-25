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

    /// One module of the checker picture and what the pixel at its center must be.
    struct ModuleCase: Sendable, CustomTestStringConvertible {
        /// What the pixel at a module's center must be.
        enum Expectation: Sendable {
            /// The pixel is opaque black.
            case opaqueBlack

            /// The pixel is clear.
            case clear
        }

        /// The module's column, from the left.
        let column: Int

        /// The module's row, from the top.
        let row: Int

        /// What the pixel at the module's center must be.
        let expectation: Expectation

        /// The name the test run shows for this case.
        var testDescription: String { "column \(column), row \(row) is \(expectation)" }

        /// Returns whether a pixel is what the module must show.
        ///
        /// - Parameter pixel: The pixel at the module's center.
        /// - Returns: Whether the pixel is the expected opaque black or clear.
        func isMet(by pixel: RGBAPixels.Pixel) -> Bool {
            switch expectation {
            case .opaqueBlack: pixel.isOpaqueBlack
            case .clear: pixel.isClear
            }
        }
    }

    /// The four modules of the checker picture: black on one diagonal, clear on the other.
    nonisolated private static let moduleCases = [
        ModuleCase(column: 0, row: 0, expectation: .opaqueBlack),
        ModuleCase(column: 1, row: 0, expectation: .clear),
        ModuleCase(column: 0, row: 1, expectation: .clear),
        ModuleCase(column: 1, row: 1, expectation: .opaqueBlack),
    ]

    /// The side of the frame the barcode fills, in points.
    private static let side = BarcodeFixture.qrCode.frameWidth

    /// The scale of the picture whose pixels are read.
    private static let scanScale = RenderScale(pixelsPerPoint: 3)

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
        of fixture: BarcodeFixture,
        layoutDirection: LayoutDirection = .leftToRight,
    ) throws -> RGBAPixels {
        let code = try fixture.content
        let view = Barcode(code, label: Text("Code"))
            .barcodeStyle(ContentOnlyBarcodeStyle())
            .frame(width: fixture.frameSize.width, height: fixture.frameSize.height)
            .environment(\.layoutDirection, layoutDirection)
        return try RGBAPixels(of: CGImage.rendering(view, atScale: Self.scanScale))
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

    @Test(arguments: moduleCases)
    func whenContentIsCustom_shouldDrawItsPixels(module: ModuleCase) throws {
        let sut = Barcode(try CheckerBarcodeContent(), label: Text("Check-in QR code"))
            .barcodeStyle(ContentOnlyBarcodeStyle())
            .frame(width: Self.side, height: Self.side)
        let pixels = try RGBAPixels(of: CGImage.rendering(sut, atScale: Self.scanScale))
        let center = Self.centerPixel(of: pixels, column: module.column, row: module.row)
        #expect(module.isMet(by: center), "The center of column \(module.column), row \(module.row) is \(center)")
    }

    @Test(arguments: BarcodeFixture.allCases)
    func whenScaledUp_shouldDrawOnlyOpaqueBlackOrClearPixels(fixture: BarcodeFixture) throws {
        let pixels = try renderedPixels(of: fixture)
        let failingCount = pixels.count(columns: pixels.columns, rows: pixels.rows) { pixel in
            !(pixel.isClear || pixel.isOpaqueBlack)
        }
        #expect(failingCount == 0, "\(failingCount) pixels are neither opaque black nor clear")
    }

    @Test(arguments: BarcodeFixture.allCases)
    func whenLayoutIsRightToLeft_shouldDrawSamePixelsAsLeftToRight(fixture: BarcodeFixture) throws {
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

    @Test(arguments: BarcodeFixture.allCases)
    func whenFramed_shouldFillFrameWithCode(fixture: BarcodeFixture) throws {
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
