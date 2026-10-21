import SwiftUI
import UIDesign

/// A square that stands in for a company's logo.
///
/// The edge keeps the tile visible on a surface of the same color. The tile is
/// hidden from VoiceOver, because the company's name sits beside it or under it.
struct SponsorLogoTile: View {
    /// How much of the tile's side the symbol takes.
    private static let symbolRatio: CGFloat = 0.5

    /// The logo the tile stands in for.
    let logo: SampleLogo

    /// How wide and tall the square is.
    let side: CGFloat

    /// How round the square's corners are.
    var cornerRadius: CornerRadius = .small

    /// The shape of the square.
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: CGFloat(cornerRadius), style: .continuous)
    }

    var body: some View {
        shape
            .fill(.tertiarySurface)
            .strokeBorder(.borderPrimary, lineWidth: CGFloat(BorderWidth.thin))
            .frame(width: side, height: side)
            .overlay {
                Image(systemName: logo.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: side * Self.symbolRatio)
                    .foregroundStyle(.textSecondary)
            }
            .accessibilityHidden(true)
    }
}
