import SwiftUI

/// A type that applies a custom appearance to all notices within a view hierarchy.
///
/// To configure the current notice style for a view hierarchy, use the
/// ``SwiftUI/View/noticeStyle(_:)`` modifier.
///
/// ```swift
/// struct PlainNoticeStyle: NoticeStyle {
///     func makeBody(configuration: Configuration) -> some View {
///         VStack(alignment: .leading) {
///             configuration.icon
///             VStack(alignment: .leading) {
///                 configuration.title
///                 configuration.description
///             }
///             .accessibilityElement(children: .combine)
///             configuration.actions
///         }
///     }
/// }
/// ```
///
/// Draw every part of the configuration. A style that leaves one out hides it from the notice.
///
/// Grouping the title and the description is the style's job. Wrap them in
/// `.accessibilityElement(children: .combine)` so VoiceOver reads them as one element, and keep
/// the actions outside the group so each action stays its own control. The configuration hides
/// the icon from VoiceOver for every style.
public protocol NoticeStyle: DynamicProperty {
    /// A view that represents the body of a notice.
    associatedtype Body: View

    /// The properties of a notice.
    typealias Configuration = NoticeStyleConfiguration

    /// Creates a view that represents the body of a notice.
    ///
    /// The system calls this method for each ``Notice`` instance in a view
    /// hierarchy where this style is the current notice style.
    ///
    /// - Parameter configuration: The properties of the notice.
    /// - Returns: A view that represents the body of a notice.
    @ViewBuilder @MainActor
    func makeBody(configuration: Configuration) -> Body
}
