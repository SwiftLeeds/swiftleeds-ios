import SFSafeSymbols
import SwiftUI

/// A view that shows a symbol on a colored background, as decoration.
///
/// The palette's gradient fills the frame. The symbol sits in the center, in a muted color.
///
/// VoiceOver does not read an artwork. It fills the frame it is given and reads no text size.
///
/// ```swift
/// Artwork(icon: Icon(.hammerFill), palette: .teal)
///     .clipShape(RoundedRectangle(cornerRadius: .tile))
/// ```
public struct Artwork: View {
    /// A set of colors for an artwork.
    public struct Palette: Equatable, Hashable, Sendable {
        /// The colors this palette draws with.
        fileprivate let family: ColorFamily

        /// A blue palette.
        public static let blue = Self(family: .blue)

        /// A teal palette.
        public static let teal = Self(family: .teal)

        /// A violet palette.
        public static let violet = Self(family: .violet)

        /// A raspberry palette.
        public static let raspberry = Self(family: .raspberry)
    }

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

    /// The symbol's size as a fraction of the art's shorter side.
    private static let symbolScale: CGFloat = 0.40

    public var body: some View {
        ZStack {
            Rectangle().fill(palette.family.solid.gradient)
            Image(icon: icon)
                .resizable()
                .scaledToFit()
                .scaleEffect(Self.symbolScale)
                .foregroundStyle(palette.family.onSolid.secondary)
        }
        .accessibilityHidden(true)
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

#Preview("Hero") {
    Artwork(icon: Icon(.hammerFill), palette: .teal)
        .frame(maxWidth: .infinity)
        .aspectRatio(3 / 2, contentMode: .fit)
}
