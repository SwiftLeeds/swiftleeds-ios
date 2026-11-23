import SFSafeSymbols
import SwiftUI

/// A view that shows a symbol as decoration.
///
/// VoiceOver does not read an artwork's symbol.
///
/// Apply `redacted(reason: .placeholder)` to show an artwork whose item is still loading.
///
/// ```swift
/// Artwork(icon: Icon(.hammerFill), palette: .teal)
///     .clipShape(RoundedRectangle(cornerRadius: .tile))
/// ```
public struct Artwork: View {
    /// A set of colors for an artwork.
    public struct Palette: Equatable, Hashable, Sendable {
        /// The colors this palette draws with.
        let family: ColorFamily

        /// A blue palette.
        public static let blue = Self(family: .blue)

        /// A teal palette.
        public static let teal = Self(family: .teal)

        /// A violet palette.
        public static let violet = Self(family: .violet)

        /// A raspberry palette.
        public static let raspberry = Self(family: .raspberry)
    }

    /// A view that draws an artwork in a given style.
    private struct ResolvedArtworkStyle<Style: ArtworkStyle>: View {
        /// The style that draws the artwork.
        let style: Style

        /// The properties of the artwork.
        let configuration: ArtworkStyleConfiguration

        var body: some View { style.makeBody(configuration: configuration) }
    }

    /// The current artwork style.
    @Environment(\.artworkStyle) private var style

    /// The symbol to draw.
    private let icon: Icon

    /// The colors to draw with.
    private let palette: Palette

    /// Creates an artwork that draws a symbol in a palette.
    ///
    /// - Parameters:
    ///   - icon: The symbol to draw.
    ///   - palette: The colors to draw with.
    public init(icon: Icon, palette: Palette) {
        self.icon = icon
        self.palette = palette
    }

    /// The artwork, drawn by the current artwork style.
    public var body: some View { AnyView(resolved(in: style)) }

    /// The properties handed to the current artwork style.
    private var configuration: ArtworkStyleConfiguration {
        ArtworkStyleConfiguration(symbol: symbol, palette: palette)
    }

    /// The symbol, fitted to the space the style gives it and hidden from VoiceOver.
    private var symbol: some View {
        Image(icon: icon)
            .resizable()
            .scaledToFit()
            .accessibilityHidden(true)
    }

    /// Returns a view that draws the artwork in the given style.
    ///
    /// - Parameter style: The style to draw the artwork in.
    /// - Returns: A view that draws the artwork in `style`.
    private func resolved(in style: some ArtworkStyle) -> some View {
        ResolvedArtworkStyle(style: style, configuration: configuration)
    }
}

#Preview("Palettes") {
    HStack(spacing: .lg) {
        Artwork(icon: Icon(.hammerFill), palette: .blue)
            .frame(avatarSize: .large)

        Artwork(icon: Icon(.hammerFill), palette: .teal)
            .frame(avatarSize: .large)

        Artwork(icon: Icon(.hammerFill), palette: .violet)
            .frame(avatarSize: .large)

        Artwork(icon: Icon(.hammerFill), palette: .raspberry)
            .frame(avatarSize: .large)
    }
    .padding(.lg)
}

#Preview("Loading") {
    HStack(spacing: .lg) {
        Artwork(icon: Icon(.hammerFill), palette: .blue)
            .frame(avatarSize: .large)

        Artwork(icon: Icon(.hammerFill), palette: .teal)
            .frame(avatarSize: .large)
    }
    .redacted(reason: .placeholder)
    .padding(.lg)
}

#Preview("Hero") {
    Artwork(icon: Icon(.hammerFill), palette: .teal)
        .frame(maxWidth: .infinity)
        .aspectRatio(3 / 2, contentMode: .fit)
}
