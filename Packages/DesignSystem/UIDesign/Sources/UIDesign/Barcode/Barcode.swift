#if canImport(CoreImage)
import SwiftUI

/// A view that draws a code for a scanner to read.
///
/// A barcode is essential content, so give it a label that names what it is. It does not
/// scale with the text size, and it ignores Smart Invert. The caller's frame sets its size.
///
/// ```swift
/// Barcode(code, label: Text("Check-in QR code"))
///     .frame(width: 220, height: 220)
/// ```
///
/// ## Making a barcode accessible
///
/// A barcode is one element. VoiceOver reads its label and says it is an image. It never
/// reads the text the code carries.
///
/// ## Choosing where the picture comes from
///
/// A barcode draws a code made on the device, or an image you supply. For a supplied image,
/// you keep the image's quiet zone: the barcode adds none.
///
/// ```swift
/// Barcode(membershipCodeImage, label: Text("Membership QR code"))
/// ```
public struct Barcode: View {
    /// A view that draws a barcode in a given style.
    private struct ResolvedBarcodeStyle<Style: BarcodeStyle>: View {
        /// The style that draws the barcode.
        let style: Style

        /// The properties of the barcode.
        let configuration: BarcodeStyleConfiguration

        var body: some View {
            style.makeBody(configuration: configuration)
        }
    }

    /// The current barcode style.
    @Environment(\.barcodeStyle) private var style

    /// The picture of the code to draw.
    private let picture: CGImage

    /// The label VoiceOver reads for the barcode.
    private let label: Text

    /// Creates a barcode that draws a code, with a label for VoiceOver.
    ///
    /// ```swift
    /// Barcode(code, label: Text("Check-in QR code"))
    /// ```
    ///
    /// - Parameters:
    ///   - code: The code to draw.
    ///   - label: The label VoiceOver reads for the barcode.
    public init(_ code: some BarcodeContent, label: Text) {
        picture = code.cgImage
        self.label = label
    }

    /// Creates a barcode that draws an image you supply, with a label for VoiceOver.
    ///
    /// The barcode adds no quiet zone, the clear margin a scanner needs around the marks. Give
    /// the image its own margin. A tightly cropped image can lose marks under the rounded
    /// corners of the plate.
    ///
    /// ```swift
    /// Barcode(membershipCodeImage, label: Text("Membership QR code"))
    /// ```
    ///
    /// - Parameters:
    ///   - image: The image to draw.
    ///   - label: The label VoiceOver reads for the barcode.
    public init(_ image: CGImage, label: Text) {
        picture = image
        self.label = label
    }

    public var body: some View {
        AnyView(resolved(in: style))
            // Smart Invert would turn the marks white, which may not scan, so it skips every style.
            .accessibilityIgnoresInvertColors()
    }

    /// The properties handed to the current barcode style.
    private var configuration: BarcodeStyleConfiguration {
        BarcodeStyleConfiguration(
            content: Image(picture, scale: 1, label: label)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
        )
    }

    /// Returns a view that draws the barcode in the given style.
    ///
    /// - Parameter style: The style to draw the barcode in.
    /// - Returns: A view that draws the barcode in `style`.
    private func resolved(in style: some BarcodeStyle) -> some View {
        ResolvedBarcodeStyle(style: style, configuration: configuration)
    }
}

#if DEBUG
extension Barcode {
    /// The made-up text the preview code carries.
    fileprivate static let previewText = "ti_ExampleTicket0000000000"

    /// The side of the preview barcode's frame.
    fileprivate static let previewSide: CGFloat = 220

    /// A barcode of made-up text in a frame on a grouped surface.
    ///
    /// When no code can be made, it shows the reason instead.
    @ViewBuilder
    fileprivate static var preview: some View {
        Group {
            switch Result(catching: { try QRCode(previewText) }) {
            case .success(let code):
                Barcode(code, label: Text("Check-in QR code"))

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
