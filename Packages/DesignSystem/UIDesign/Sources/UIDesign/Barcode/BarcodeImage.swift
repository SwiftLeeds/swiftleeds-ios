#if canImport(CoreImage)
import CoreGraphics
import CoreImage

/// The drawing steps every barcode shares, from the generator's picture to a rendered image.
enum BarcodeImage {
    /// The clear border a scanner needs around a code.
    struct QuietZone: Equatable, Hashable, Sendable {
        /// The width of the border, counted in modules.
        fileprivate let modules: Int

        /// Creates a quiet zone of the given width.
        ///
        /// - Parameter modules: The width of the border on each side, in modules.
        init(modules: Int) {
            self.modules = modules
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

    /// Returns a generated code as an image with alpha, at most ten pixels for each module.
    ///
    /// - Parameters:
    ///   - generated: The generator's picture: black modules on white.
    ///   - missingQuietZone: The quiet zone the generator leaves out, added clear.
    /// - Returns: The image, or `nil` when CoreImage draws none.
    static func render(_ generated: CIImage, addingQuietZone missingQuietZone: QuietZone) -> CGImage? {
        let marks = blackModulesOnClear(generated)
        let picture = scaledUp(addingQuietZone(missingQuietZone, to: marks))
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

    /// Returns a picture where each dark module is opaque black and everything else is clear.
    ///
    /// - Parameter generated: The generator's black on white picture.
    /// - Returns: The picture with the white turned clear.
    private static func blackModulesOnClear(_ generated: CIImage) -> CIImage {
        let inverted = generated.applyingFilter("CIColorInvert")
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
#endif
