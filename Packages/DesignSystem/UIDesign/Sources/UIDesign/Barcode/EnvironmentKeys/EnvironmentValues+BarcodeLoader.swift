#if canImport(CoreImage)
import SwiftUI

extension EnvironmentValues {
    /// The loader that fetches the picture of a barcode from a URL.
    @Entry package var barcodeLoader: BarcodeLoader = .live
}
#endif
