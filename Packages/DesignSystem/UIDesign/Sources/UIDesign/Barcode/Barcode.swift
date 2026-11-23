#if canImport(CoreImage)
import SwiftUI

/// A view that draws a QR code for a scanner to read.
///
/// A barcode is essential content, so give it a label that names what it is. It does not
/// scale with the text size. The caller's frame sets its size.
///
/// ```swift
/// Barcode(code, label: Text("Ticket QR code"))
///     .frame(width: 220, height: 220)
/// ```
///
/// ## Making a barcode accessible
///
/// A barcode is one element. VoiceOver reads its label and says it is an image. It never
/// reads the text the code carries.
public struct Barcode: View {
    /// The code to draw.
    private let code: QRCode

    /// The label VoiceOver reads for the barcode.
    private let label: Text

    /// Creates a barcode that draws a QR code, with a label for VoiceOver.
    ///
    /// ```swift
    /// Barcode(code, label: Text("Ticket QR code"))
    /// ```
    ///
    /// - Parameters:
    ///   - code: The code to draw.
    ///   - label: The label VoiceOver reads for the barcode.
    public init(_ code: QRCode, label: Text) {
        self.code = code
        self.label = label
    }

    public var body: some View {
        Image(code, label: label)
    }
}

#if DEBUG
extension Barcode {
    /// The made-up text the preview code carries.
    fileprivate static let previewText = "ti_ExampleTicket0000000000"

    /// The side of the preview barcode's frame.
    fileprivate static let previewSide: CGFloat = 220

    /// A barcode of made-up text in a frame on a grouped surface, or the reason there is none.
    @ViewBuilder
    fileprivate static var preview: some View {
        Group {
            switch Result(catching: { try QRCode(previewText) }) {
            case .success(let code):
                Barcode(code, label: Text("Ticket QR code"))

            case .failure(let error):
                Text("No code: \(String(describing: error))")
            }
        }
        .frame(width: previewSide, height: previewSide)
        .padding()
        .background(.groupedSurface)
    }
}

#Preview("Light") {
    Barcode.preview
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    Barcode.preview
        .preferredColorScheme(.dark)
}
#endif
#endif
