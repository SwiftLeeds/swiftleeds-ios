#if canImport(CoreImage)
import CoreGraphics

/// A type that supplies the picture of a code for a ``Barcode`` to draw.
///
/// The picture is opaque black modules on clear, with the code's quiet zone included. Each module
/// is a whole number of pixels, so the view can scale it up without blurring the edges.
public protocol BarcodeContent: Equatable, Hashable, Sendable {
    /// The code as an image: black modules on clear, with its quiet zone.
    var cgImage: CGImage { get }
}
#endif
