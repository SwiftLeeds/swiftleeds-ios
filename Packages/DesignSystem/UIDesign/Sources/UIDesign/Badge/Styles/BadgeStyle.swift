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
/// An environment value or `ScaledMetric` on the style itself does not update. To answer the
/// color scheme or the Dynamic Type size, return a view that reads it.
///
/// ```swift
/// func makeBody(configuration: Configuration) -> some View {
///     ScaledBadge(configuration: configuration) // a view with its own @ScaledMetric
/// }
/// ```
public protocol BadgeStyle: DynamicProperty {
    /// A view that represents the body of a badge.
    associatedtype Body: View

    /// The properties of a badge.
    typealias Configuration = BadgeStyleConfiguration

    /// Creates a view that represents the body of a badge.
    ///
    /// The system calls this method for each `Badge` instance in a view
    /// hierarchy where this style is the current badge style.
    ///
    /// - Parameter configuration: The properties of the badge.
    /// - Returns: A view that represents the body of a badge.
    @ViewBuilder @MainActor
    func makeBody(configuration: Configuration) -> Body
}
