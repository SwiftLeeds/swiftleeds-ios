import SwiftUI

/// A badge style that draws the label in the family's text color on a pale capsule.
///
/// You can also use ``BadgeStyle/automatic`` to construct this style.
public struct TintedBadgeStyle: BadgeStyle {
    /// A view that draws a badge's label on a capsule, with padding that grows with the text.
    private struct Capsuled: View {
        /// How far the text size has grown from its default.
        ///
        /// It scales 1 rather than a length, because the padding tokens are fixed, so each
        /// one multiplies by it.
        @ScaledMetric(relativeTo: .caption) private var textScale: CGFloat = 1

        /// The properties of the badge.
        let configuration: BadgeStyleConfiguration

        var body: some View {
            configuration.label
                .labelStyle(.titleAndIcon)
                .labelIconToTitleSpacing(.xs)
                .imageScale(.small)
                .font(.caption.weight(.semibold))
                .foregroundStyle(configuration.colors.text)
                .padding(.horizontal, .sm, scaledBy: textScale)
                .padding(.vertical, .xxs, scaledBy: textScale)
                .background(configuration.colors.subtle, in: Capsule())
        }
    }

    /// Creates a tinted badge style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        Capsuled(configuration: configuration)
    }
}

extension BadgeStyle where Self == TintedBadgeStyle {
    /// A badge style that draws the label in the family's text color on a pale capsule.
    public static var tinted: TintedBadgeStyle { TintedBadgeStyle() }

    /// The default badge style, which is ``tinted``.
    public static var automatic: TintedBadgeStyle { TintedBadgeStyle() }
}
