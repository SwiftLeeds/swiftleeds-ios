#if canImport(CoreImage)
import CoreGraphics

/// A type that supplies the picture of a code for a ``Barcode`` to draw.
///
/// The picture is opaque black marks on clear.
public protocol BarcodeContent: Equatable, Hashable, Sendable {
    /// The code as an image: opaque black marks on clear.
    var cgImage: CGImage { get }
}
#endif
