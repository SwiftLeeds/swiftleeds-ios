import CoreGraphics
import CoreImage

/// A kind of machine-readable code, and the rules for drawing one.
///
/// Each symbology owns its own quiet zone — the light margin a scanner needs to find the code.
/// The required width differs per symbology.
package protocol BarcodeSymbology: Sendable {
    associatedtype Payload: Sendable

    /// Draws `payload` as a code image, or returns `nil` if this symbology cannot encode it.
    @MainActor func makeImage(encoding payload: Payload) -> CGImage?
}

/// Turns a generator's output into a bitmap, adding a quiet zone where the generator omits one.
@MainActor
enum BarcodeImage {
    // Software rendering: barcodes are a few thousand pixels at most, and standing up a
    // GPU-backed context costs far more than drawing one.
    private static let context = CIContext(options: [.useSoftwareRenderer: true])

    /// Renders `image`, widening its light margin by `modules` on every side.
    static func render(_ image: CIImage, addingQuietZoneOf modules: CGFloat) -> CGImage? {
        let source = modules > 0
            ? image.composited(over: quietZone(around: image.extent, of: modules))
            : image
        return context.createCGImage(source, from: source.extent)
    }

    private static func quietZone(around extent: CGRect, of modules: CGFloat) -> CIImage {
        CIImage(color: .white).cropped(to: extent.insetBy(dx: -modules, dy: -modules))
    }
}
