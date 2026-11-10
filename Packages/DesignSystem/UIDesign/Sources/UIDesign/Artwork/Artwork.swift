import SFSafeSymbols
import SwiftUI

/// A view that shows a symbol on a colored background, as decoration.
///
/// The palette's gradient fills the frame. The symbol sits in the center, in a muted color.
///
/// VoiceOver does not read an artwork. It fills the frame it is given and reads no text size.
///
/// Apply `redacted(reason: .placeholder)` to show an artwork whose item is still loading. It then
/// draws a plain shape.
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

    /// The current redaction reasons applied to the view hierarchy.
    @Environment(\.redactionReasons) private var redactionReasons

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

    /// The symbol's size as a fraction of the largest size that fits the frame.
    private static let symbolScale: CGFloat = 0.40

    /// The artwork, or a plain fill while it loads.
    public var body: some View {
        Group {
            if redactionReasons.contains(.placeholder) {
                placeholder
            } else {
                art
            }
        }
        .accessibilityHidden(true)
    }

    /// A plain shape that shows no palette and no symbol.
    private var placeholder: some View {
        Rectangle().fill(.avatarFill)
    }

    /// The palette's gradient with the symbol in the center.
    private var art: some View {
        ZStack {
            Rectangle().fill(palette.family.solid.gradient)
            Image(icon: icon)
                .resizable()
                .scaledToFit()
                .scaleEffect(Self.symbolScale)
                .foregroundStyle(palette.family.onSolid.secondary)
        }
        .dynamicTypeSize(.large)
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
