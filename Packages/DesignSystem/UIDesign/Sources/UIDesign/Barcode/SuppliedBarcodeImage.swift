#if canImport(CoreImage)
import CoreGraphics

/// A picture of a code made elsewhere, drawn as black marks on clear.
///
/// It holds an image the caller supplies, or one a ``Barcode`` fetches. The image can be in any
/// colors, such as light blue on white. Each pixel becomes opaque black where the image is dark,
/// and clear where it is light. A clear pixel in the image counts as light.
///
/// The image keeps its size and its margin. The caller keeps the quiet zone: this type adds none,
/// so a tightly cropped image can lose marks under the plate's rounded corners.
///
/// An image with no marks draws as clear. An all white, all black or almost white image has none.
///
/// Two values are equal when one is a copy of the other. Two values made separately from the same
/// image are not equal.
///
/// ```swift
/// let membership = try SuppliedBarcodeImage(membershipCodeImage)
/// Barcode(membership, label: Text("Membership QR code"))
/// ```
public struct SuppliedBarcodeImage: BarcodeContent {
    /// The reason an image does not become marks on clear.
    public enum ValidationError: Error, Equatable, Sendable {
        /// CoreImage drew nothing.
        case notDrawn
    }

    /// The image as opaque black marks on clear.
    public let cgImage: CGImage

    /// Creates a picture of the marks in an image.
    ///
    /// ```swift
    /// let marks = try SuppliedBarcodeImage(membershipCodeImage)
    /// ```
    ///
    /// - Parameter image: The image to read, in any colors. A clear pixel counts as light.
    /// - Throws: ``ValidationError/notDrawn`` when CoreImage draws no picture of the image.
    public init(_ image: CGImage) throws(ValidationError) {
        guard let marks = BarcodeImage.thresholded(image) else { throw .notDrawn }
        cgImage = marks
    }

    /// Returns whether two values share one picture.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.cgImage === rhs.cgImage
    }

    /// Hashes the identity of the picture.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(cgImage))
    }
}
#endif
