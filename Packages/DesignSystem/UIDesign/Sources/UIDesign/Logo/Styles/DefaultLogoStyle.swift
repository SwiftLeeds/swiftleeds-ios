import SwiftUI

/// The default logo style.
///
/// It draws the mark inset on a rounded square, filled with the surface color, or with the
/// secondary color in dark mode. Increase Contrast adds an outline.
///
/// You can also use ``LogoStyle/automatic`` to construct this style.
public struct DefaultLogoStyle: LogoStyle {
    /// The share of the tile that the mark may fill.
    private struct MarkScale {
        /// The fraction of the tile's side that a mark fills, which leaves a margin around it.
        private static let insetFraction: CGFloat = 0.75

        /// The share a mark fills, which leaves a margin around it.
        static let inset = Self(fraction: insetFraction)

        /// The share a placeholder fills, which is the whole tile.
        static let whole = Self(fraction: 1)

        /// The fraction of the tile's side, from 0 to 1.
        let fraction: CGFloat

        /// Returns a view shrunk to this share of the space it was given.
        ///
        /// - Parameter view: The view to shrink.
        /// - Returns: A view drawn at this share of its size.
        func applied(to view: some View) -> some View {
            view.scaleEffect(fraction)
        }
    }

    /// The current redaction reasons applied to the view hierarchy.
    @Environment(\.redactionReasons) private var redactionReasons

    /// The current color scheme.
    @Environment(\.colorScheme) private var colorScheme

    /// The rounded square the logo is drawn on.
    private var tile: RoundedRectangle {
        RoundedRectangle(cornerRadius: .tile)
    }

    /// What the tile is filled with: the secondary color in dark mode, the surface color otherwise.
    private var tileFill: AnyShapeStyle {
        colorScheme == .dark ? AnyShapeStyle(Color.secondary) : AnyShapeStyle(BrandShapeStyle.surface)
    }

    /// Creates the default logo style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        let scale = redactionReasons.contains(.placeholder) ? MarkScale.whole : MarkScale.inset
        return Color.clear
            .overlay { scale.applied(to: configuration.content) }
            .background(tileFill, in: tile)
            .clipShape(tile)
            .overlay { tile.strokeBorder(.border, lineWidth: .edge) }
            .overlay { tile.strokeBorder(.avatarOutline, lineWidth: .outline) }
    }
}

extension LogoStyle where Self == DefaultLogoStyle {
    /// The default logo style.
    public static var automatic: DefaultLogoStyle { DefaultLogoStyle() }
}
