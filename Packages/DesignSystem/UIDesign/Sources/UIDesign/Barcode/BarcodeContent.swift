#if canImport(CoreImage)
import CoreGraphics

/// A type that supplies the picture of a code for a ``Barcode`` to draw.
///
/// A barcode draws the picture as given and does not change its colors. Opaque black marks on
/// clear scan on the barcode's plate. A conforming type may supply other colors; check that a code
/// in those colors still scans.
public protocol BarcodeContent: Equatable, Hashable, Sendable {
    /// The code as an image.
    var cgImage: CGImage { get }
}
#endif
