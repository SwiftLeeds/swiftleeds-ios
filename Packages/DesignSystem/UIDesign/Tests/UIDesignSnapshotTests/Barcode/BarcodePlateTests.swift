#if os(iOS)
import QuartzCore
import SwiftUI
import Testing
import UIDesign
import UIDesignTestSupport
import UIKit

@MainActor
@Suite
struct BarcodePlateTests {
    /// One brand, appearance and kind of code to check the plate under.
    struct PlateCase: Sendable, CustomTestStringConvertible {
        /// The brand the barcode reads from its environment.
        let brand: Brand

        /// The appearance the host is drawn in.
        let appearance: SystemAppearance

        /// The kind of code drawn.
        let fixture: BarcodeFixture

        /// The name the test run shows for this case.
        var testDescription: String { "\(brand) \(appearance.name) \(fixture)" }
    }

    /// The reason a test could not read the barcode's render.
    private enum ProbeError: Error {
        /// The render never showed the code's marks.
        case codeNeverDrawn
    }

    /// The made-up text the code carries.
    private static let text = BarcodeFixture.qrCode.text

    /// The modules across the fixture's code with its quiet zone.
    private static let modulesWithQuietZone = Double(BarcodeFixture.qrCode.layout.modulesAcross)

    /// How far inside the quiet zone's far edge the middle of its innermost row sits.
    ///
    /// It is counted in modules, so the row's middle sits that far short of the code's first mark.
    private static let innermostRowInset = 0.5

    /// How far either side of a finder edge the blended pixels are counted.
    ///
    /// It is counted in modules, so the count covers one module, centered on the edge.
    private static let edgeNeighborhood = 0.5

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

    /// The scale of the window picture whose pixels are read.
    private static let windowScale = RenderScale(pixelsPerPoint: 3)

    /// The width, in pixels, of the plate's rounded corner at each side.
    ///
    /// The plate is not drawn there.
    private static let cornerRadiusInPixels = Int(
        (CGFloat(CornerRadius.tile.level) * CGFloat(windowScale)).rounded(.up)
    )

    /// The most a channel may sit from the plate's, out of 255.
    private static let channelTolerance = 8

    /// The largest value of one 8-bit channel.
    private static let channelMaximum = Float(UInt8.max)

    /// The appearances the plate is checked under.
    nonisolated private static let appearances: [SystemAppearance] = [
        .light,
        .dark,
        .lightIncreasedContrast,
        .darkIncreasedContrast,
    ]

    /// Every brand under every appearance with every kind of code.
    nonisolated private static let plateCases: [PlateCase] = Brand.allCases.flatMap { brand in
        appearances.flatMap { appearance in
            BarcodeFixture.allCases.map { PlateCase(brand: brand, appearance: appearance, fixture: $0) }
        }
    }

    /// Returns the pixels of a default barcode on a grouped surface, drawn on screen.
    ///
    /// - Parameters:
    ///   - brand: The brand the barcode reads from its environment.
    ///   - appearance: The appearance the host is drawn in.
    ///   - fixture: The kind of code to draw. The default is the QR code.
    /// - Returns: The pixels of the render, at the render scale.
    /// - Throws: ``ProbeError/codeNeverDrawn`` when the code's marks never show in the render.
    ///   Also when the code, the render or the pixels cannot be made.
    private static func renderedPixels(
        brand: Brand,
        appearance: SystemAppearance,
        fixture: BarcodeFixture = .qrCode,
    ) async throws -> RGBAPixels {
        try RGBAPixels(of: try await renderedImage(brand: brand, appearance: appearance, fixture: fixture))
    }

    /// Returns the picture of a default barcode on a grouped surface, drawn on screen.
    ///
    /// - Parameters:
    ///   - brand: The brand the barcode reads from its environment.
    ///   - appearance: The appearance the host is drawn in.
    ///   - fixture: The kind of code to draw. The default is the QR code.
    /// - Returns: The picture of the render, at the render scale.
    /// - Throws: ``ProbeError/codeNeverDrawn`` when the code's marks never show in the render.
    ///   Also when the code, the render or the pixels cannot be made.
    private static func renderedImage(
        brand: Brand,
        appearance: SystemAppearance,
        fixture: BarcodeFixture = .qrCode,
    ) async throws -> CGImage {
        let size = fixture.frameSize
        let view = Barcode(try fixture.content, label: Text("Code"))
            .frame(width: size.width, height: size.height)
            .background(.groupedSurface)
            .environment(\.brand, brand)
        let host = UIHostingController(rootView: view.ignoresSafeArea())
        // Traits, not `EnvironmentValues`, because the environment cannot set Increase Contrast.
        host.traitOverrides.userInterfaceStyle = appearance.isLight ? .light : .dark
        host.traitOverrides.accessibilityContrast = appearance.withoutIncreasedContrast == nil ? .normal : .high
        let frame = CGRect(origin: .zero, size: size)
        let window = (SceneFreeWindow() as any WindowMaking).makeWindow(frame: frame)
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.frame = frame
        host.view.layoutIfNeeded()
        for _ in 0..<attempts {
            let image = try image(of: window)
            if showsMarks(in: try RGBAPixels(of: image), of: fixture) { return image }
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
        format.scale = CGFloat(windowScale)
        let image = UIGraphicsImageRenderer(size: window.bounds.size, format: format).image { context in
            window.layer.render(in: context.cgContext)
        }
        return try #require(image.cgImage)
    }

    /// Returns whether a module that is dark in the stored code is dark in a render.
    ///
    /// - Parameters:
    ///   - pixels: The render to read.
    ///   - fixture: The kind of code the render draws.
    /// - Returns: Whether the pixel there is black.
    private static func showsMarks(in pixels: RGBAPixels, of fixture: BarcodeFixture) -> Bool {
        let layout = fixture.layout
        let column = Int(layout.darkColumn * Double(pixels.width) / Double(layout.modulesAcross))
        let row = Int(layout.darkRow * Double(pixels.height) / Double(layout.modulesDown))
        return isDark(pixels.pixel(at: PixelPosition(column: column, row: row)))
    }

    /// Returns whether a pixel is opaque and dark enough to be a mark.
    ///
    /// - Parameter pixel: The pixel drawn.
    /// - Returns: Whether alpha is full and every color channel is at most ``drawnMarkCeiling``.
    private static func isDark(_ pixel: RGBAPixels.Pixel) -> Bool {
        pixel.alpha == UInt8.max && max(pixel.red, pixel.green, pixel.blue) <= drawnMarkCeiling
    }

    /// Returns the places where only the plate may show.
    ///
    /// - Parameters:
    ///   - pixels: The render to sample.
    ///   - fixture: The kind of code the render draws.
    /// - Returns: Every pixel of the quiet zone's innermost row, inside the plate's rounded corners.
    private static func plateSamples(in pixels: RGBAPixels, of fixture: BarcodeFixture) -> [PixelPosition] {
        // This render blurs a one-module ring, so only the quiet zone's row can be read exactly.
        let layout = fixture.layout
        let rowModules = Double(layout.quietZone) - innermostRowInset
        let ringRow = Int(rowModules * Double(pixels.height) / Double(layout.modulesDown))
        let columns = cornerRadiusInPixels..<(pixels.width - cornerRadiusInPixels)
        return columns.map { PixelPosition(column: $0, row: ringRow) }
    }

    /// Returns the pixel the plate has under an appearance.
    ///
    /// The rule is written here, apart from the token the plate reads, so a wrong plate cannot
    /// agree with its own expectation. The plate is the brand's surface in light mode. Only dark
    /// mode at standard contrast uses the brand's secondary surface, also in light mode.
    ///
    /// - Parameters:
    ///   - brand: The brand whose plate to read.
    ///   - appearance: The appearance the plate is drawn in.
    /// - Returns: The plate as an opaque 8-bit pixel.
    private static func platePixel(of brand: Brand, in appearance: SystemAppearance) -> RGBAPixels.Pixel {
        let isDarkAtStandardContrast = !appearance.isLight && appearance.withoutIncreasedContrast == nil
        let source = isDarkAtStandardContrast ? brand.secondarySurface : brand.surface
        let light = UITraitCollection(userInterfaceStyle: .light)
        let resolved = Color(UIColor(source).resolvedColor(with: light))
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

    @Test(arguments: plateCases)
    func whenDrawn_shouldShowScannableSurfaceThroughLightAreas(plateCase: PlateCase) async throws {
        let (brand, appearance, fixture) = (plateCase.brand, plateCase.appearance, plateCase.fixture)
        let pixels = try await Self.renderedPixels(brand: brand, appearance: appearance, fixture: fixture)
        let plate = Self.platePixel(of: brand, in: appearance)
        let samples = Self.plateSamples(in: pixels, of: fixture)
        let failing = samples.filter { !Self.isPlate(pixels.pixel(at: $0), plate) }
        let shown = failing.first.map { pixels.pixel(at: $0) }
        let summary = "\(failing.count) of \(samples.count) samples miss the plate \(plate)"
        #expect(
            failing.isEmpty,
            "\(brand) \(appearance.name) \(fixture): \(summary), first drawn \(String(describing: shown))",
        )
    }

    @Test(arguments: BarcodeFixture.allCases)
    func whenStored_shouldSpanWholeModules(fixture: BarcodeFixture) throws {
        let image = try fixture.content.cgImage
        let layout = fixture.layout
        let pixelsPerModule = image.width / layout.modulesAcross
        #expect(image.width == layout.modulesAcross * pixelsPerModule, "\(fixture): width is not whole modules")
        #expect(image.height == layout.modulesDown * pixelsPerModule, "\(fixture): height is not whole modules")
    }

    @Test(arguments: BarcodeFixture.allCases)
    func whenStored_shouldBeDarkAtPollModule(fixture: BarcodeFixture) throws {
        let image = try fixture.content.cgImage
        let layout = fixture.layout
        let pixelsPerModule = image.width / layout.modulesAcross
        let pixels = try RGBAPixels(of: image)
        let column = Int(layout.darkColumn * Double(pixelsPerModule))
        let row = Int(layout.darkRow * Double(pixelsPerModule))
        let position = PixelPosition(column: column, row: row)
        #expect(Self.isDark(pixels.pixel(at: position)), "\(fixture): the poll module is not dark")
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
        let failing = (first...last).filter {
            !Self.isPlate(pixels.pixel(at: PixelPosition(column: $0, row: row)), plate)
        }
        let shown = failing.first.map { pixels.pixel(at: PixelPosition(column: $0, row: row)) }
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
            let first = Self.position(ofModules: edge - Self.edgeNeighborhood, in: pixels)
            let last = Self.position(ofModules: edge + Self.edgeNeighborhood, in: pixels)
            return (first..<last).count { column in
                let pixel = pixels.pixel(at: PixelPosition(column: column, row: row))
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
        let decoded = try QRCodeScanner.payload(in: image)
        var shown = "nothing"
        if let decoded { shown = "\"\(decoded)\"" }
        #expect(decoded == Self.text, "\(brand) \(appearance.name): decoded \(shown), expected \(Self.text)")
    }
}
#endif
