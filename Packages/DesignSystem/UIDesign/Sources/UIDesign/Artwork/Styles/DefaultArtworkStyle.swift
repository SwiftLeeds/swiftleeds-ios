import SwiftUI

/// The default artwork style.
///
/// It draws the symbol on a colored background. The palette's gradient fills the frame. The
/// symbol sits in the center, in a muted color. The artwork reads no text size.
///
/// When the artwork is redacted as a placeholder, it draws a plain gray fill with no gradient and no symbol.
///
/// You can also use ``ArtworkStyle/automatic`` to construct this style.
public struct DefaultArtworkStyle: ArtworkStyle {
    /// The symbol's size as a fraction of the largest size that fits the frame.
    private static let symbolScale: CGFloat = 0.40

    /// The current redaction reasons applied to the view hierarchy.
    @Environment(\.redactionReasons) private var redactionReasons

    /// A plain shape that shows no palette and no symbol.
    private var placeholder: some View {
        Rectangle().fill(.secondaryFill)
    }

    /// Creates the default artwork style.
    public init() {}

    /// Creates a view that draws the gradient and symbol, or a gray fill while loading.
    ///
    /// - Parameter configuration: The properties of the artwork.
    /// - Returns: A view that represents the body of an artwork.
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        if redactionReasons.contains(.placeholder) {
            placeholder
        } else {
            art(configuration)
        }
    }

    /// Returns the palette's gradient with the symbol in the center.
    ///
    /// - Parameter configuration: The properties of the artwork.
    /// - Returns: The gradient with the tinted symbol over it, at the default text size.
    private func art(_ configuration: Configuration) -> some View {
        ZStack {
            Rectangle().fill(configuration.palette.family.solid.gradient)
            configuration.symbol
                .scaleEffect(Self.symbolScale)
                .foregroundStyle(configuration.palette.family.onSolid.secondary)
        }
        .dynamicTypeSize(.large)
    }
}

extension ArtworkStyle where Self == DefaultArtworkStyle {
    /// The default artwork style.
    public static var automatic: DefaultArtworkStyle { DefaultArtworkStyle() }
}
