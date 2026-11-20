import SwiftUI

/// A badge style that draws the label on a solid capsule of the family's color.
///
/// Use it for a badge that must stand out, such as a live state.
public struct FilledBadgeStyle: BadgeStyle {
    /// Creates a filled badge style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BadgeCapsule(
            configuration: configuration,
            fill: configuration.colors.solid,
            foreground: configuration.colors.onSolid,
        )
    }
}

extension BadgeStyle where Self == FilledBadgeStyle {
    /// A badge style that draws the label on a solid capsule of the family's color.
    public static var filled: FilledBadgeStyle { FilledBadgeStyle() }
}
