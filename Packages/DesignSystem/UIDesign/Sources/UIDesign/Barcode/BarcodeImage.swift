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

    /// Returns a generated code as an image with alpha, one pixel for each module.
    ///
    /// - Parameters:
    ///   - generated: The generator's picture: black modules on white.
    ///   - missingQuietZone: The quiet zone the generator leaves out, added clear.
    /// - Returns: The image, or `nil` when CoreImage draws none.
    static func render(_ generated: CIImage, addingQuietZone missingQuietZone: QuietZone) -> CGImage? {
        let marks = blackModulesOnClear(generated)
        let picture = addingQuietZone(missingQuietZone, to: marks)
        return context.createCGImage(picture, from: picture.extent)
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
