import CoreGraphics

/// A payload paired with the symbology that draws it.
package struct BarcodeContent {
    private let draw: @MainActor () -> CGImage?

    package init<Symbology: BarcodeSymbology>(
        _ payload: Symbology.Payload,
        drawnBy symbology: Symbology
    ) {
        draw = { symbology.makeImage(encoding: payload) }
    }

    /// Draws the code, or returns `nil` if the payload cannot be encoded.
    @MainActor package func makeImage() -> CGImage? {
        draw()
    }
}
