#if canImport(CoreImage)

/// The stage of loading the picture that a barcode draws.
package enum BarcodeLoadingPhase: Equatable, Hashable, Sendable {
    /// No picture has loaded yet.
    case empty

    /// A loaded picture, as marks on clear.
    case success(SuppliedBarcodeImage)

    /// A load that gave no picture.
    case failure
}
#endif
