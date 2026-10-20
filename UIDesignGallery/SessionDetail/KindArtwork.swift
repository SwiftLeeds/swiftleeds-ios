import SwiftUI

/// A view that fills its frame with a session kind's generic art.
///
/// The art runs past the safe area on both sides, and the symbol stays
/// centered in the frame inside it.
struct KindArtwork: View {
    /// The kind of session the art stands for.
    let kind: SessionKind

    /// How much of the top the symbol stays clear of, in points.
    var topInset: CGFloat = 0

    /// How much of the bottom the symbol stays clear of, in points.
    ///
    /// Text that sits over the art's foot sets this, so the symbol never
    /// meets it.
    var bottomInset: CGFloat = 0

    /// The color scheme the art draws for.
    @Environment(\.colorScheme) private var colorScheme

    /// The size of the kind's symbol, in points.
    private static let symbolSize: CGFloat = 64

    /// The clear space the symbol keeps above and below itself, in points.
    private static let symbolClearance: CGFloat = 16

    /// How strongly the symbol shows against the field.
    private static let symbolOpacity: Double = 0.5

    var body: some View {
        Color.clear
            .background {
                LinearGradient(
                    colors: kind.artColors(in: colorScheme),
                    startPoint: .top,
                    endPoint: .bottom,
                )
                .ignoresSafeArea(.container, edges: .horizontal)
            }
            .overlay {
                symbol
                    .padding(.top, topInset)
                    .padding(.bottom, bottomInset)
            }
            .accessibilityHidden(true)
    }

    /// The kind's symbol, centered across the clear area, or nothing where the
    /// area is too short to hold it with its clearance.
    private var symbol: some View {
        ViewThatFits(in: .vertical) {
            Image(systemName: kind.symbol)
                .font(.system(size: Self.symbolSize))
                .foregroundStyle(.white.opacity(Self.symbolOpacity))
                .frame(minHeight: Self.symbolSize + 2 * Self.symbolClearance)

            Color.clear
        }
    }
}
