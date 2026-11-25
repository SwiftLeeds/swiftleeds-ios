#if os(iOS)
import CoreGraphics
import UIDesign
import UIDesignTestSupport

/// A made-up barcode content of two by two modules, dark on one diagonal, for the barcode suites.
struct CheckerBarcodeContent: BarcodeContent {
    /// The modules in each row and each column of the picture.
    static let modulesAcross = 2

    /// The picture: black at the top left and bottom right, clear elsewhere.
    let cgImage: CGImage

    /// Creates the content.
    ///
    /// - Throws: ``RGBAPixels/DrawingError/notDrawn`` when CoreGraphics makes no picture.
    init() throws(RGBAPixels.DrawingError) {
        let pixels = try RGBAPixels(
            width: Self.modulesAcross,
            height: Self.modulesAcross,
            pixels: [.black, .clear, .clear, .black],
        )
        cgImage = try pixels.image
    }

    /// Returns whether two contents are equal: every checker is the same picture.
    static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }

    /// Hashes the size, because every checker is the same picture.
    func hash(into hasher: inout Hasher) {
        hasher.combine(Self.modulesAcross)
    }
}
#endif
