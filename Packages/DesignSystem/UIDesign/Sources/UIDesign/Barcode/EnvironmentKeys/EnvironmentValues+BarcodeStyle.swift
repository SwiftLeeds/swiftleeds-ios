#if canImport(CoreImage)
import SwiftUI

extension EnvironmentValues {
    /// The barcode style applied to the view hierarchy.
    @Entry public var barcodeStyle: any BarcodeStyle = .automatic
}

extension View {
    /// Sets the style for barcodes within this view.
    ///
    /// ```swift
    /// VStack {
    ///     Barcode(code, label: Text("Check-in QR code"))
    /// }
    /// .barcodeStyle(.automatic)
    /// ```
    ///
    /// - Parameter style: The barcode style to apply.
    /// - Returns: A view that uses the given style for the barcodes within it.
    public func barcodeStyle(_ style: some BarcodeStyle) -> some View {
        environment(\.barcodeStyle, style)
    }
}
#endif
