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
