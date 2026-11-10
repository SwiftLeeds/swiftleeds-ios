import SwiftUI

/// A badge style that draws the label in the family's text color on a pale capsule.
///
/// You can also use ``BadgeStyle/automatic`` to construct this style.
public struct TintedBadgeStyle: BadgeStyle {
    /// Creates a tinted badge style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption.weight(.semibold))
            .foregroundStyle(configuration.colors.text)
            .padding(.horizontal, .sm)
            .padding(.vertical, .xxs)
            .background(configuration.colors.subtle, in: Capsule())
    }
}

extension BadgeStyle where Self == TintedBadgeStyle {
    /// A badge style that draws the label in the family's text color on a pale capsule.
    public static var tinted: TintedBadgeStyle { TintedBadgeStyle() }

    /// The default badge style, which is ``tinted``.
    public static var automatic: TintedBadgeStyle { TintedBadgeStyle() }
}
