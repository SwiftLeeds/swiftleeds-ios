import SwiftUI

/// The default logo style.
///
/// Like `DefaultButtonStyle` and `DefaultLabelStyle`, it is reached as ``LogoStyle/automatic``.
public struct DefaultLogoStyle: LogoStyle {
    /// The share of the tile that the mark may fill.
    private struct MarkScale {
        /// The fraction of the tile's side that a mark fills, which leaves a margin around it.
        private static let insetFraction: CGFloat = 0.75

        /// The share a mark fills, which leaves a margin around it.
        static let inset = Self(fraction: insetFraction)

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

    /// The rounded square the logo is drawn on.
    private var tile: some Shape {
        RoundedRectangle(cornerRadius: .tile)
    }

    /// Creates the default logo style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        Color.clear
            .overlay { MarkScale.inset.applied(to: configuration.content) }
            .background(.surface, in: tile)
            .clipShape(tile)
    }
}

extension LogoStyle where Self == DefaultLogoStyle {
    /// The default logo style.
    public static var automatic: DefaultLogoStyle { DefaultLogoStyle() }
}
