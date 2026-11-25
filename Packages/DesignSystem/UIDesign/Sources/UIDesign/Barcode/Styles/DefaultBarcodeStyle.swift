#if canImport(CoreImage)
import SwiftUI

/// The default barcode style.
///
/// It draws the code on the brand's scannable surface, in a rounded tile.
///
/// You can also use ``BarcodeStyle/automatic`` to construct this style.
public struct DefaultBarcodeStyle: BarcodeStyle {
    /// The rounded square the code is drawn on.
    private var tile: RoundedRectangle {
        RoundedRectangle(cornerRadius: .tile)
    }

    /// Creates the default barcode style.
    public init() {}

    /// Creates a view that represents the body of a barcode.
    ///
    /// The system calls this method for each ``Barcode`` instance in a view
    /// hierarchy where this style is the current barcode style.
    ///
    /// - Parameter configuration: The properties of the barcode.
    /// - Returns: A view that represents the body of a barcode.
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .background(.scannableSurface, in: tile)
            .clipShape(tile)
    }
}

extension BarcodeStyle where Self == DefaultBarcodeStyle {
    /// The default barcode style.
    public static var automatic: DefaultBarcodeStyle { DefaultBarcodeStyle() }
}
#endif
