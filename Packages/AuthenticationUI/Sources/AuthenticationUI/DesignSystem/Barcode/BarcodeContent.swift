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

    /// Creates content that draws itself with `draw`.
    ///
    /// - Parameter draw: Returns the code image, or `nil` if it cannot be drawn.
    package init(draw: @escaping @MainActor () -> CGImage?) {
        self.draw = draw
    }

    /// Draws the code, or returns `nil` if the payload cannot be encoded.
    @MainActor package func makeImage() -> CGImage? {
        draw()
    }
}
