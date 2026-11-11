import SwiftUI

/// A type that applies a custom appearance to all badges within a view hierarchy.
///
/// To configure the current badge style for a view hierarchy, use the
/// ``SwiftUI/View/badgeStyle(_:)`` modifier.
///
/// ```swift
/// struct PlainBadgeStyle: BadgeStyle {
///     func makeBody(configuration: Configuration) -> some View {
///         configuration.label
///             .font(.caption)
///     }
/// }
/// ```
///
/// Draw the configuration's label. A style that leaves it out hides the badge's word.
///
/// A style may read the environment, such as the color scheme or the Dynamic Type size.
///
/// Inside a `List`, a `Label` takes the list's label style unless the style sets one, as the
/// built-in styles set `.titleAndIcon`.
public protocol BadgeStyle: DynamicProperty {
    /// A view that represents the body of a badge.
    associatedtype Body: View

    /// The properties of a badge.
    typealias Configuration = BadgeStyleConfiguration

    /// Creates a view that represents the body of a badge.
    ///
    /// The system calls this method for each ``Badge`` instance in a view
    /// hierarchy where this style is the current badge style.
    ///
    /// - Parameter configuration: The properties of the badge.
    /// - Returns: A view that represents the body of a badge.
    @ViewBuilder @MainActor
    func makeBody(configuration: Configuration) -> Body
}
