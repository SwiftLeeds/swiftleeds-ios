import SwiftUI

/// A type that applies a custom appearance to all avatar groups within a view
/// hierarchy.
///
/// To configure the current avatar group style for a view hierarchy, use the
/// ``SwiftUI/View/avatarGroupStyle(_:)`` modifier.
///
/// ```swift
/// struct StackedAvatarGroupStyle: AvatarGroupStyle {
///     func makeBody(configuration: Configuration) -> some View {
///         VStack {
///             configuration.content
///             configuration.overflow
///         }
///     }
/// }
/// ```
///
/// A style may read the environment, so it can answer the color scheme and the
/// Dynamic Type size.
public protocol AvatarGroupStyle: DynamicProperty {
    /// A view that represents the body of an avatar group.
    associatedtype Body: View

    /// The properties of an avatar group.
    typealias Configuration = AvatarGroupStyleConfiguration

    /// Creates a view that represents the body of an avatar group.
    ///
    /// The system calls this method for each `AvatarGroup` instance in a view
    /// hierarchy where this style is the current avatar group style.
    ///
    /// - Parameter configuration: The properties of the avatar group.
    /// - Returns: A view that represents the body of an avatar group.
    @ViewBuilder @MainActor
    func makeBody(configuration: Configuration) -> Body
}
