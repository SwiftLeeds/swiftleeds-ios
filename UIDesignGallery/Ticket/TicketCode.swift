import CoreImage.CIFilterBuiltins
import SwiftUI
import UIDesign

/// A view that shows a QR code on a white plate.
///
/// The plate is white in light and dark mode, because a scanner reads dark
/// marks on a light ground. The code is content, but a scanner reads it at one
/// size, so it does not scale with the text size.
struct TicketCode: View {
    /// The QR code to show, one pixel to a module.
    let image: CGImage

    /// How wide and tall the code is, without the plate around it.
    private static let side: CGFloat = 188

    /// How much white surrounds the code, which a scanner needs to find its edges.
    private static let quietZone: Spacing = .large

    var body: some View {
        Image(decorative: image, scale: 1)
            .resizable()
            .interpolation(.none)
            .frame(width: Self.side, height: Self.side)
            .padding(Self.quietZone)
            .background(
                .white,
                in: RoundedRectangle(cornerRadius: CGFloat(CornerRadius.small), style: .continuous),
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Ticket QR code")
            .accessibilityHint("Hold this up to be scanned")
    }
}

extension TicketCode {
    /// How much redundancy the code carries, so a scratch does not break it.
    private static let correctionLevel = "M"

    /// Returns a QR code for some text, or `nil` when the system cannot draw one.
    ///
    /// - Parameter payload: The text the code carries.
    static func image(for payload: String) -> CGImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(payload.utf8)
        filter.correctionLevel = correctionLevel
        return filter.outputImage.flatMap { output in
            CIContext().createCGImage(output, from: output.extent)
        }
    }
}
