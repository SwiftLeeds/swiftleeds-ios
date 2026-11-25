#if os(macOS)
import SwiftUI
import Testing
import UIDesign
import UIDesignTestSupport

@MainActor
struct BarcodePlateScanTests {
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
        func point(width: Int, height: Int, inset: Int) -> PixelPosition {
            switch self {
            case .top: PixelPosition(column: width / 2, row: inset)
            case .left: PixelPosition(column: inset, row: height / 2)
            case .bottom: PixelPosition(column: width / 2, row: height - 1 - inset)
            case .right: PixelPosition(column: width - 1 - inset, row: height / 2)
            }
        }
    }

    /// The scale of the picture whose plate is checked and scanned.
    private static let scanScale = RenderScale(pixelsPerPoint: 2)

    /// How far in from an edge a plate sample sits, in modules.
    ///
    /// Every code keeps at least two clear modules at its edge, so this stays in the quiet zone.
    private static let plateInsetModules = 1.0

    /// How far a channel may sit from its expected value, out of 255.
    private static let channelTolerance = 8

    /// The largest value of one channel.
    private static let largestChannel = Int(UInt8.max)

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

    /// Returns whether a pixel is opaque and the color of the plate.
    ///
    /// - Parameters:
    ///   - pixels: The rendered picture.
    ///   - point: The pixel to read.
    ///   - expected: The color the plate should be.
    /// - Returns: `true` when the pixel is opaque and each channel is within the tolerance.
    private static func isPlate(
        _ pixels: RGBAPixels,
        at point: PixelPosition,
        matching expected: Color.Resolved,
    ) -> Bool {
        let pixel = pixels.pixel(at: point)
        guard Int(pixel.alpha) >= largestChannel - channelTolerance else { return false }
        let wanted = [expected.red, expected.green, expected.blue].map(byteValue(of:))
        let drawn = [pixel.red, pixel.green, pixel.blue].map(Int.init)
        return zip(wanted, drawn).allSatisfy { abs($1 - $0) <= channelTolerance }
    }

    /// Checks the plate at the middle of each edge's quiet zone.
    ///
    /// - Parameters:
    ///   - pixels: The rendered picture.
    ///   - fixture: The fixture the picture draws.
    ///   - plate: The color the plate should be.
    private func expectPlate(in pixels: RGBAPixels, of fixture: BarcodeFixture, matching plate: Color) {
        let expected = Self.resolvedLight(plate)
        let inset = Int(Double(pixels.width) / Double(fixture.modulesAcross) * Self.plateInsetModules)
        for edge in Edge.allCases {
            let point = edge.point(width: pixels.width, height: pixels.height, inset: inset)
            let isPlate = Self.isPlate(pixels, at: point, matching: expected)
            #expect(isPlate, "The plate is missing or the wrong color at the \(edge) edge")
        }
    }

    /// Renders a view, checks its plate, then scans the picture.
    ///
    /// - Parameters:
    ///   - view: The view to render.
    ///   - fixture: The fixture the view draws.
    ///   - plate: The color the plate should be.
    /// - Throws: When the picture cannot be made or read.
    private func expectScan(of view: some View, fixture: BarcodeFixture, plate: Color) throws {
        let image = try CGImage.rendering(view, atScale: Self.scanScale)
        expectPlate(in: try RGBAPixels(of: image), of: fixture, matching: plate)
        #expect(BarcodeReader.payload(of: image, as: fixture.symbology) == fixture.text)
    }

    @Test(arguments: Brand.allCases, BarcodeFixture.generated)
    func whenDrawnWithDefaultStyle_shouldScanBackAsCodeText(brand: Brand, fixture: BarcodeFixture) throws {
        let code = try fixture.content
        let view = Barcode(code, label: Text("Code"))
            .frame(width: fixture.frameWidth, height: fixture.frameHeight)
            .environment(\.brand, brand)
        try expectScan(of: view, fixture: fixture, plate: brand.surface)
    }

    @Test(arguments: Brand.allCases, BarcodeFixture.generated)
    func whenCodeIsOnSecondarySurfaceColor_shouldScanBackAsCodeText(brand: Brand, fixture: BarcodeFixture) throws {
        // macOS never picks the secondary surface, so this paints the plate itself instead of using `Barcode`.
        let code = try fixture.content
        let plate = Color(Self.resolvedLight(brand.secondarySurface))
        let view = Image(code.cgImage, scale: 1, label: Text("Code"))
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .frame(width: fixture.frameWidth, height: fixture.frameHeight)
            .background(plate)
        try expectScan(of: view, fixture: fixture, plate: brand.secondarySurface)
    }
}
#endif
