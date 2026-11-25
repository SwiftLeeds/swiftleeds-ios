#if canImport(CoreImage)
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins

/// The drawing steps every barcode shares, from the generator's picture to a rendered image.
package enum BarcodeImage {
    /// The clear border a scanner needs around a code.
    package struct QuietZone: Equatable, Hashable, Sendable {
        /// The width of the border, counted in modules.
        ///
        /// It is unsigned, so a border cannot be negative.
        fileprivate let modules: UInt

        /// Creates a quiet zone of the given width.
        ///
        /// - Parameter modules: The width of the border on each side, in modules.
        package init(modules: UInt) {
            self.modules = modules
        }

        /// Returns the border to add so a margin that exists reaches a required width.
        ///
        /// This zone is the margin already there. A margin as wide as the requirement, or wider,
        /// needs no addition.
        ///
        /// - Parameter required: The width the border must reach.
        /// - Returns: The difference, or a zero-width border when this margin is wide enough.
        package func missing(toReach required: Self) -> Self {
            Self(modules: required.modules - min(modules, required.modules))
        }
    }

    /// The context that renders every barcode, in software so the result is the same everywhere.
    private static let context = CIContext(options: [.useSoftwareRenderer: true])

    /// The most pixels the image spends on each module.
    private static let pixelsPerModule = 10

    /// The most pixels the longer side of the image spans, unless one pixel for each module needs more.
    private static let longerSideCap = 2_048

    /// The fewest pixels the image spends on each module.
    private static let fewestPixelsPerModule = 1

    /// The number of tones a supplied image is merged into before the cut.
    ///
    /// It merges faint noise into one tone, so a flat area is not split into marks.
    private static let toneLevels: Float = 16

    /// Returns a generated code as an image with alpha, at most ten pixels for each module.
    ///
    /// - Parameters:
    ///   - generated: The generator's picture: black modules on white.
    ///   - generatorMargin: The clear margin the generator already leaves around the code.
    ///   - required: The quiet zone the code needs. Clear border is added only where the margin falls short.
    /// - Returns: The image, or `nil` when CoreImage draws none.
    static func render(
        _ generated: CIImage,
        generatorMargin: QuietZone,
        reaching required: QuietZone,
    ) -> CGImage? {
        let marks = blackModulesOnClear(generated)
        let missing = generatorMargin.missing(toReach: required)
        let picture = scaledUp(addingQuietZone(missing, to: marks))
        return context.createCGImage(picture, from: picture.extent)
    }

    /// Returns a picture with each module drawn as a square of whole pixels, with hard edges.
    ///
    /// - Parameter picture: The picture at one pixel for each module.
    /// - Returns: The picture at the whole number of pixels for each module that ``wholePixelsPerModule(for:)`` gives.
    private static func scaledUp(_ picture: CIImage) -> CIImage {
        let scale = CGFloat(wholePixelsPerModule(for: picture))
        return picture.samplingNearest().transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    }

    /// Returns the largest whole number of pixels for each module that keeps the longer side within the cap.
    ///
    /// - Parameter picture: The picture at one pixel for each module.
    /// - Returns: A number from ``fewestPixelsPerModule`` to ``pixelsPerModule``.
    private static func wholePixelsPerModule(for picture: CIImage) -> Int {
        let longerSide = Int(max(picture.extent.width, picture.extent.height))
        return min(pixelsPerModule, max(fewestPixelsPerModule, longerSideCap / longerSide))
    }

    /// Returns an image made elsewhere as opaque black marks on clear, at its own size.
    ///
    /// Each pixel is judged light or dark by the picture's own tones, so a code in any colors
    /// gives marks. The image is not scaled and gets no quiet zone. Faint noise is merged into
    /// one tone first, so a flat image gives no marks.
    ///
    /// - Parameter image: The image to read. A clear pixel counts as light.
    /// - Returns: The marks, or `nil` when CoreImage draws none.
    static func thresholded(_ image: CGImage) -> CGImage? {
        let source = CIImage(cgImage: image)
        guard let tones = posterized(backedWithWhite(source)) else { return nil }
        let filter = CIFilter.colorThresholdOtsu()
        filter.inputImage = tones
        guard let blackOnWhite = filter.outputImage else { return nil }
        let marks = blackModulesOnClear(blackOnWhite)
        return context.createCGImage(marks, from: marks.extent)
    }

    /// Returns a picture backed with opaque white, so a clear pixel counts as light.
    ///
    /// - Parameter picture: The picture to back.
    /// - Returns: The picture over white, cropped to the picture's extent.
    private static func backedWithWhite(_ picture: CIImage) -> CIImage {
        picture.composited(over: CIImage(color: .white).cropped(to: picture.extent))
    }

    /// Returns a picture with its tones merged into a few levels.
    ///
    /// Faint noise in a flat area falls into one tone, so the cut finds no marks there.
    ///
    /// - Parameter tones: The picture to merge.
    /// - Returns: The picture at ``toneLevels`` levels, or `nil` when CoreImage draws none.
    private static func posterized(_ tones: CIImage) -> CIImage? {
        let filter = CIFilter.colorPosterize()
        filter.inputImage = tones
        filter.levels = toneLevels
        return filter.outputImage
    }

    /// Returns a picture where each dark module is opaque black and everything else is clear.
    ///
    /// - Parameter blackOnWhite: A black on white picture, from the generator or a threshold.
    /// - Returns: The picture with the white turned clear.
    private static func blackModulesOnClear(_ blackOnWhite: CIImage) -> CIImage {
        let inverted = blackOnWhite.applyingFilter("CIColorInvert")
        let masked = inverted.applyingFilter("CIMaskToAlpha")
        return masked.applyingFilter(
            "CIColorMatrix",
            parameters: [
                "inputRVector": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1),
            ],
        )
    }

    /// Returns a picture with a quiet zone added around it, clear.
    ///
    /// - Parameters:
    ///   - quietZone: The border to add.
    ///   - marks: The picture to extend.
    /// - Returns: The picture with a clear border on every side.
    private static func addingQuietZone(_ quietZone: QuietZone, to marks: CIImage) -> CIImage {
        let border = CGFloat(quietZone.modules)
        let extended = marks.extent.insetBy(dx: -border, dy: -border)
        return marks.composited(over: CIImage(color: .clear).cropped(to: extended))
    }
}

extension Float {
    /// Creates the width of a quiet zone, for a generator that takes its margin as a number.
    ///
    /// - Parameter zone: The quiet zone to read.
    init(_ zone: BarcodeImage.QuietZone) {
        self = Float(zone.modules)
    }
}
#endif
