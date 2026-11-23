#if canImport(CoreImage)
import SwiftUI

/// The default barcode style.
///
/// It draws the barcode's symbol as it is.
///
/// You can also use ``BarcodeStyle/automatic`` to construct this style.
public struct DefaultBarcodeStyle: BarcodeStyle {
    /// Creates the default barcode style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        configuration.content
    }
}

extension BarcodeStyle where Self == DefaultBarcodeStyle {
    /// The default barcode style.
    public static var automatic: DefaultBarcodeStyle { DefaultBarcodeStyle() }
}
#endif
