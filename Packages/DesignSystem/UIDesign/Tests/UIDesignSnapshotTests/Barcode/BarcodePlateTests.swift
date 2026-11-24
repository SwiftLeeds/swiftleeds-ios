#if os(iOS)
import CoreImage
import QuartzCore
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite
struct BarcodePlateTests {
    /// A place in the render where the plate must show.
    private struct Sample: Equatable, Hashable, Sendable {
        /// The column of the pixel, from the left.
        let column: Int

        /// The row of the pixel, from the top.
        let row: Int
    }

    /// The reason a test could not read the barcode's render.
    private enum ProbeError: Error {
        /// The render never showed the code's marks.
        case codeNeverDrawn
    }

    /// The made-up text the code carries.
    private static let text = "ti_ExampleTicket0000000000"

    /// The modules across the fixture's code with its quiet zone.
    ///
    /// The code is 29 modules in version 3, and the quiet zone adds 4 on each side.
    private static let modulesWithQuietZone = 37.0

    /// How far into the code the middle of the quiet zone's innermost row sits.
    ///
    /// It is counted in modules.
    private static let ringRowOffset = 3.5

    /// How far into the code the black center of the top-leading finder pattern sits.
    ///
    /// It is counted in modules, to the middle of that center.
    private static let finderMarkOffset = 7.5

    /// How far into the render the middle of the finder's one-module light ring sits.
    ///
    /// It is counted in modules, to the middle of the ring's leading side.
    private static let finderLightRingOffset = 5.5

    /// How far either side of the ring's middle the plate must show.
    ///
    /// It is counted in modules, and half the ring's width leaves its edges unchecked.
    private static let finderLightRingHalfSpan = 0.25

    /// Where the finder's edges lie along its center row.
    ///
    /// Each is a boundary between a black and a light module, counted in modules from the leading edge.
    private static let finderEdgeOffsets = [4.0, 5.0, 6.0, 9.0, 10.0, 11.0]

    /// The most pixels at one edge that may be neither plate nor black.
    private static let mostBlendedPixelsPerEdge = 2

    /// The brightest channel, out of 255, that still counts as a black mark.
    ///
    /// The test uses it to check that the code was drawn.
    private static let drawnMarkCeiling: UInt8 = 96

    /// How many times the render is read before the test gives up.
    private static let attempts = 50

    /// How long to wait between two reads of the render.
    private static let pollInterval = Duration.milliseconds(20)

    /// The side of the frame the barcode fills, in points.
    private static let side: CGFloat = 220

    /// The number of pixels in one point of the render.
    private static let renderScale: CGFloat = 3

    /// The width, in pixels, of the plate's rounded corner at each side.
    ///
    /// The plate is not drawn there.
    private static let cornerRadiusInPixels = Int((CGFloat(CornerRadius.tile.level) * renderScale).rounded(.up))

    /// The most a channel may sit from the plate's, out of 255.
    private static let channelTolerance = 8

    /// The largest value of one 8-bit channel.
    private static let channelMaximum: Float = 255

    /// The appearances the plate is checked under.
    nonisolated private static let appearances: [SystemAppearance] = [
        .light,
        .dark,
        .lightIncreasedContrast,
        .darkIncreasedContrast,
    ]

    /// Returns the pixels of a default barcode on a grouped surface, drawn on screen.
    ///
    /// - Parameters:
    ///   - brand: The brand the barcode reads from its environment.
    ///   - appearance: The appearance the host is drawn in.
    /// - Returns: The pixels of the render, at the render scale.
    /// - Throws: ``ProbeError/codeNeverDrawn`` when the code's marks never show in the render.
    ///   Also when the code, the render or the pixels cannot be made.
    private static func renderedPixels(brand: Brand, appearance: SystemAppearance) async throws -> RGBAPixels {
        try RGBAPixels(of: try await renderedImage(brand: brand, appearance: appearance))
    }

    /// Returns the picture of a default barcode on a grouped surface, drawn on screen.
    ///
    /// - Parameters:
    ///   - brand: The brand the barcode reads from its environment.
    ///   - appearance: The appearance the host is drawn in.
    /// - Returns: The picture of the render, at the render scale.
    /// - Throws: ``ProbeError/codeNeverDrawn`` when the code's marks never show in the render.
    ///   Also when the code, the render or the pixels cannot be made.
    private static func renderedImage(brand: Brand, appearance: SystemAppearance) async throws -> CGImage {
        let view = Barcode(try QRCode(text), label: Text("Ticket QR code"))
            .frame(width: side, height: side)
            .background(.groupedSurface)
            .environment(\.brand, brand)
        let host = UIHostingController(rootView: view.ignoresSafeArea())
        // Traits, not `EnvironmentValues`, because the environment cannot set Increase Contrast.
        host.traitOverrides.userInterfaceStyle = appearance.isLight ? .light : .dark
        host.traitOverrides.accessibilityContrast = appearance.withoutIncreasedContrast == nil ? .normal : .high
        let frame = CGRect(x: 0, y: 0, width: side, height: side)
        let window = (SceneFreeWindow() as any WindowMaking).makeWindow(frame: frame)
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.frame = frame
        host.view.layoutIfNeeded()
        for _ in 0..<attempts {
            let image = try image(of: window)
            if showsMarks(in: try RGBAPixels(of: image)) { return image }
            try await Task.sleep(for: pollInterval)
        }
        throw ProbeError.codeNeverDrawn
    }

    /// Returns the picture of what a window shows now.
    ///
    /// - Parameter window: The window to read.
    /// - Returns: The window's picture, at the render scale.
    /// - Throws: When the picture cannot be made.
    private static func image(of window: UIWindow) throws -> CGImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = renderScale
        let image = UIGraphicsImageRenderer(size: window.bounds.size, format: format).image { context in
            window.layer.render(in: context.cgContext)
        }
        return try #require(image.cgImage)
    }

    /// Returns the text a QR code in a picture carries.
    ///
    /// - Parameter image: The picture to scan.
    /// - Returns: The text of the first QR code found, or `nil` when there is none.
    /// - Throws: When the detector cannot be made.
    private static func decodedText(in image: CGImage) throws -> String? {
        let detector = try #require(
            CIDetector(
                ofType: CIDetectorTypeQRCode,
                context: nil,
                options: [CIDetectorAccuracy: CIDetectorAccuracyHigh],
            )
        )
        let features = detector.features(in: CIImage(cgImage: image))
        return features.compactMap { ($0 as? CIQRCodeFeature)?.messageString }.first
    }

    /// Returns whether the top-leading finder pattern's black center shows in a render.
    ///
    /// - Parameter pixels: The render to read.
    /// - Returns: Whether the pixel there is black.
    private static func showsMarks(in pixels: RGBAPixels) -> Bool {
        let place = Int(finderMarkOffset * Double(pixels.width) / modulesWithQuietZone)
        let pixel = pixels.pixel(x: place, y: place)
        return pixel.alpha == UInt8.max && max(pixel.red, pixel.green, pixel.blue) <= drawnMarkCeiling
    }

    /// Returns the places where only the plate may show.
    ///
    /// - Parameter pixels: The render to sample.
    /// - Returns: Every pixel of the quiet zone's innermost row.
    private static func plateSamples(in pixels: RGBAPixels) -> [Sample] {
        // This render blurs a one-module ring, so only the quiet zone's row can be read exactly.
        let ringRow = Int(ringRowOffset * Double(pixels.width) / modulesWithQuietZone)
        let columns = cornerRadiusInPixels..<(pixels.width - cornerRadiusInPixels)
        return columns.map { Sample(column: $0, row: ringRow) }
    }

    /// Returns the pixel the plate has under an appearance.
    ///
    /// - Parameters:
    ///   - brand: The brand whose plate to read.
    ///   - appearance: The appearance to resolve the plate under.
    /// - Returns: The plate as an opaque 8-bit pixel.
    private static func platePixel(of brand: Brand, in appearance: SystemAppearance) -> RGBAPixels.Pixel {
        let resolved = Color(UIColor(brand.scannableSurface).resolvedColor(with: appearance.traits))
            .resolve(in: EnvironmentValues())
        return RGBAPixels.Pixel(
            red: channel(resolved.red),
            green: channel(resolved.green),
            blue: channel(resolved.blue),
            alpha: UInt8.max,
        )
    }

    /// Returns a color component as an 8-bit channel.
    ///
    /// - Parameter component: The component, from 0 to 1.
    /// - Returns: The channel, from 0 to 255.
    private static func channel(_ component: Float) -> UInt8 {
        UInt8((min(max(component, 0), 1) * channelMaximum).rounded())
    }

    /// Returns whether a pixel is within the tolerance of the plate in every channel.
    ///
    /// - Parameters:
    ///   - pixel: The pixel drawn.
    ///   - plate: The pixel the plate has.
    /// - Returns: Whether red, green and blue are each within ``channelTolerance``.
    private static func isPlate(_ pixel: RGBAPixels.Pixel, _ plate: RGBAPixels.Pixel) -> Bool {
        abs(Int(pixel.red) - Int(plate.red)) <= channelTolerance
            && abs(Int(pixel.green) - Int(plate.green)) <= channelTolerance
            && abs(Int(pixel.blue) - Int(plate.blue)) <= channelTolerance
    }

    @Test(arguments: Brand.allCases, appearances)
    func whenDrawn_shouldShowScannableSurfaceThroughLightAreas(
        brand: Brand,
        appearance: SystemAppearance,
    ) async throws {
        let pixels = try await Self.renderedPixels(brand: brand, appearance: appearance)
        let plate = Self.platePixel(of: brand, in: appearance)
        let samples = Self.plateSamples(in: pixels)
        let failing = samples.filter { !Self.isPlate(pixels.pixel(x: $0.column, y: $0.row), plate) }
        let shown = failing.first.map { pixels.pixel(x: $0.column, y: $0.row) }
        let summary = "\(failing.count) of \(samples.count) samples miss the plate \(plate)"
        #expect(
            failing.isEmpty,
            "\(brand) \(appearance.name): \(summary), first drawn \(String(describing: shown))",
        )
    }

    /// Returns the pixel position of a distance counted in modules.
    ///
    /// - Parameters:
    ///   - modules: The distance from the leading or top edge, in modules.
    ///   - pixels: The render the distance is measured in.
    /// - Returns: The position, in whole pixels.
    private static func position(ofModules modules: Double, in pixels: RGBAPixels) -> Int {
        Int(modules * Double(pixels.width) / modulesWithQuietZone)
    }

    /// Returns whether a pixel is opaque black, within the tolerance of every channel.
    ///
    /// - Parameter pixel: The pixel drawn.
    /// - Returns: Whether red, green and blue are each within ``channelTolerance`` of 0, and alpha is full.
    private static func isBlack(_ pixel: RGBAPixels.Pixel) -> Bool {
        pixel.alpha == UInt8.max && Int(max(pixel.red, pixel.green, pixel.blue)) <= channelTolerance
    }

    @Test(arguments: Brand.allCases, appearances)
    func whenDrawn_shouldShowFinderLightRingAsPlate(brand: Brand, appearance: SystemAppearance) async throws {
        let pixels = try await Self.renderedPixels(brand: brand, appearance: appearance)
        let plate = Self.platePixel(of: brand, in: appearance)
        let first = Self.position(ofModules: Self.finderLightRingOffset - Self.finderLightRingHalfSpan, in: pixels)
        let last = Self.position(ofModules: Self.finderLightRingOffset + Self.finderLightRingHalfSpan, in: pixels)
        let row = Self.position(ofModules: Self.finderMarkOffset, in: pixels)
        let failing = (first...last).filter { !Self.isPlate(pixels.pixel(x: $0, y: row), plate) }
        let shown = failing.first.map { pixels.pixel(x: $0, y: row) }
        let summary = "\(failing.count) of \(last - first + 1) ring pixels miss the plate \(plate)"
        #expect(
            failing.isEmpty,
            "\(brand) \(appearance.name): \(summary), first drawn \(String(describing: shown))",
        )
    }

    @Test(arguments: Brand.allCases, appearances)
    func whenDrawn_shouldBlendAtMostTwoPixelsPerEdge(brand: Brand, appearance: SystemAppearance) async throws {
        let pixels = try await Self.renderedPixels(brand: brand, appearance: appearance)
        let plate = Self.platePixel(of: brand, in: appearance)
        let row = Self.position(ofModules: Self.finderMarkOffset, in: pixels)
        let blended = Self.finderEdgeOffsets.map { edge in
            let first = Self.position(ofModules: edge - 0.5, in: pixels)
            let last = Self.position(ofModules: edge + 0.5, in: pixels)
            return (first..<last).count { column in
                let pixel = pixels.pixel(x: column, y: row)
                return !Self.isPlate(pixel, plate) && !Self.isBlack(pixel)
            }
        }
        #expect(
            blended.allSatisfy { $0 <= Self.mostBlendedPixelsPerEdge },
            "\(brand) \(appearance.name): blended pixels at each edge \(blended)",
        )
    }

    @Test(arguments: Brand.allCases, appearances)
    func whenDrawn_shouldScanBackAsCodeText(brand: Brand, appearance: SystemAppearance) async throws {
        let image = try await Self.renderedImage(brand: brand, appearance: appearance)
        let decoded = try Self.decodedText(in: image)
        var shown = "nothing"
        if let decoded { shown = "\"\(decoded)\"" }
        #expect(decoded == Self.text, "\(brand) \(appearance.name): decoded \(shown), expected \(Self.text)")
    }
}
#endif
