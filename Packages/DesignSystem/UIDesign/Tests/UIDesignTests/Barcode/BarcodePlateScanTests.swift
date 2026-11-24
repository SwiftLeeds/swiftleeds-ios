#if os(macOS)
import SwiftUI
import Testing
import UIDesign

@MainActor
struct BarcodePlateScanTests {
    /// A pixel position in a rendered picture.
    private struct PlatePoint {
        /// The column, from the left.
        let column: Int

        /// The row, from the top.
        let row: Int
    }

    /// One edge of the plate.
    private enum Edge: CaseIterable, Sendable {
        /// The top edge.
        case top

        /// The left edge.
        case left

        /// The bottom edge.
        case bottom

        /// The right edge.
        case right

        /// Returns the point at the middle of this edge, a distance in from it.
        ///
        /// - Parameters:
        ///   - width: The width of the picture in pixels.
        ///   - height: The height of the picture in pixels.
        ///   - inset: How far in from the edge the point sits, in pixels.
        /// - Returns: The point.
        func point(width: Int, height: Int, inset: Int) -> PlatePoint {
            switch self {
            case .top: PlatePoint(column: width / 2, row: inset)
            case .left: PlatePoint(column: inset, row: height / 2)
            case .bottom: PlatePoint(column: width / 2, row: height - 1 - inset)
            case .right: PlatePoint(column: width - 1 - inset, row: height / 2)
            }
        }
    }

    /// The pixels in one point of the render.
    private static let renderScale: CGFloat = 2

    /// The pixels the stored picture spends on each module.
    private static let storedPixelsPerModule = 10

    /// How far in from an edge a plate sample sits, in modules.
    ///
    /// Every code keeps at least two clear modules at its edge, so this stays in the quiet zone.
    private static let plateInsetModules = 1.0

    /// How far a channel may sit from its expected value, out of 255.
    private static let channelTolerance = 8

    /// The largest value of one channel.
    private static let largestChannel = 255

    /// The bytes that describe one pixel: red, green, blue and alpha.
    private static let bytesPerPixel = 4

    /// The position of the alpha byte in a pixel.
    private static let alphaOffset = 3

    /// Returns a color as it resolves in light mode.
    ///
    /// - Parameter color: The color to resolve.
    /// - Returns: The color's red, green, blue and opacity in light mode.
    private static func resolvedLight(_ color: Color) -> Color.Resolved {
        var light = EnvironmentValues()
        light.colorScheme = .light
        return color.resolve(in: light)
    }

    /// Returns a channel as a whole number out of 255.
    ///
    /// - Parameter value: The channel, from 0 to 1.
    /// - Returns: The channel, from 0 to 255.
    private static func byteValue(of value: Float) -> Int {
        Int((value * Float(largestChannel)).rounded())
    }

    /// Returns one byte of a pixel.
    ///
    /// - Parameters:
    ///   - pixels: The rendered picture.
    ///   - offset: The byte in the pixel: 0 red, 1 green, 2 blue, 3 alpha.
    ///   - point: The pixel to read.
    /// - Returns: The byte, from 0 to 255.
    private static func byte(_ pixels: RenderedPixels, _ offset: Int, at point: PlatePoint) -> Int {
        Int(pixels.bytes[(point.row * pixels.side + point.column) * bytesPerPixel + offset])
    }

    /// Returns whether a pixel is opaque and the color of the plate.
    ///
    /// - Parameters:
    ///   - pixels: The rendered picture.
    ///   - point: The pixel to read.
    ///   - expected: The color the plate should be.
    /// - Returns: `true` when the pixel is opaque and each channel is within the tolerance.
    private static func isPlate(
        _ pixels: RenderedPixels,
        at point: PlatePoint,
        matching expected: Color.Resolved,
    ) -> Bool {
        let alpha = byte(pixels, alphaOffset, at: point)
        guard alpha >= largestChannel - channelTolerance else { return false }
        let wanted = [expected.red, expected.green, expected.blue].map(byteValue(of:))
        return wanted.enumerated().allSatisfy { channel in
            abs(byte(pixels, channel.offset, at: point) - channel.element) <= channelTolerance
        }
    }

    /// Checks the plate at the middle of each edge's quiet zone.
    ///
    /// - Parameters:
    ///   - pixels: The rendered picture.
    ///   - code: The code the picture draws.
    ///   - plate: The color the plate should be.
    private func expectPlate(in pixels: RenderedPixels, of code: any BarcodeContent, matching plate: Color) {
        let expected = Self.resolvedLight(plate)
        let height = pixels.bytes.count / Self.bytesPerPixel / pixels.side
        let modules = code.cgImage.width / Self.storedPixelsPerModule
        let inset = Int(Double(pixels.side) / Double(modules) * Self.plateInsetModules)
        for edge in Edge.allCases {
            let point = edge.point(width: pixels.side, height: height, inset: inset)
            let isPlate = Self.isPlate(pixels, at: point, matching: expected)
            #expect(isPlate, "The plate is missing or the wrong color at the \(edge) edge")
        }
    }

    /// Renders a view, checks its plate, then scans the picture.
    ///
    /// - Parameters:
    ///   - view: The view to render.
    ///   - fixture: The fixture the view draws.
    ///   - code: The code the view draws.
    ///   - plate: The color the plate should be.
    /// - Throws: When the picture cannot be made or read.
    private func expectScan(
        of view: some View,
        fixture: BarcodeFixture,
        code: any BarcodeContent,
        plate: Color,
    ) throws {
        let renderer = ImageRenderer(content: view)
        renderer.scale = Self.renderScale
        let image = try #require(renderer.cgImage)
        expectPlate(in: try RenderedPixels(of: image), of: code, matching: plate)
        #expect(BarcodeReader.payload(of: image, as: fixture.symbology) == fixture.text)
    }

    @Test(arguments: Brand.allCases, BarcodeFixture.allCases)
    func whenDrawnWithDefaultStyle_shouldScanBackAsCodeText(brand: Brand, fixture: BarcodeFixture) throws {
        let code = try fixture.makeContent()
        let view = Barcode(code, label: Text("Code"))
            .frame(width: fixture.frameWidth, height: fixture.frameHeight)
            .environment(\.brand, brand)
        try expectScan(of: view, fixture: fixture, code: code, plate: brand.surface)
    }

    @Test(arguments: Brand.allCases, BarcodeFixture.allCases)
    func whenDrawnOnSecondarySurface_shouldScanBackAsCodeText(brand: Brand, fixture: BarcodeFixture) throws {
        let code = try fixture.makeContent()
        let plate = Color(Self.resolvedLight(brand.secondarySurface))
        let view = Image(code.cgImage, scale: 1, label: Text("Code"))
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .frame(width: fixture.frameWidth, height: fixture.frameHeight)
            .background(plate)
        try expectScan(of: view, fixture: fixture, code: code, plate: brand.secondarySurface)
    }
}
#endif
