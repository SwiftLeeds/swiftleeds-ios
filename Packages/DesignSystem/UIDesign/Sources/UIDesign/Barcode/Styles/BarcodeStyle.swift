#if canImport(CoreImage)
import SwiftUI

/// A type that applies a custom appearance to all barcodes within a view hierarchy.
///
/// To configure the current barcode style for a view hierarchy, use the
/// ``SwiftUI/View/barcodeStyle(_:)`` modifier.
///
/// ```swift
/// struct PlainBarcodeStyle: BarcodeStyle {
///     func makeBody(configuration: Configuration) -> some View {
///         configuration.content
///     }
/// }
/// ```
///
/// Draw the configuration's content. A style that leaves it out hides the barcode's symbol.
///
/// A scanner reads dark marks on a light ground. A style that tints the marks, or puts a
/// colored plate behind them, may stop the code scanning.
///
/// A style may read the environment, such as the color scheme or the Dynamic Type size.
public protocol BarcodeStyle: DynamicProperty {
    /// A view that represents the body of a barcode.
    associatedtype Body: View

    /// The properties of a barcode.
    typealias Configuration = BarcodeStyleConfiguration

    /// Creates a view that represents the body of a barcode.
    ///
    /// The system calls this method for each ``Barcode`` instance in a view
    /// hierarchy where this style is the current barcode style.
    ///
    /// - Parameter configuration: The properties of the barcode.
    /// - Returns: A view that represents the body of a barcode.
    @ViewBuilder @MainActor
    func makeBody(configuration: Configuration) -> Body
}
#endif
