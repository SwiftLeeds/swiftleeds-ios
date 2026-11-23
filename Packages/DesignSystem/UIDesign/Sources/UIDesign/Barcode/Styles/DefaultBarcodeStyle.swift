#if canImport(CoreImage)
import SwiftUI

/// The default barcode style.
///
/// It draws the code on the brand's scannable surface.
///
/// You can also use ``BarcodeStyle/automatic`` to construct this style.
public struct DefaultBarcodeStyle: BarcodeStyle {
    /// Creates the default barcode style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .background(.scannableSurface)
    }
}

extension BarcodeStyle where Self == DefaultBarcodeStyle {
    /// The default barcode style.
    public static var automatic: DefaultBarcodeStyle { DefaultBarcodeStyle() }
}
#endif
