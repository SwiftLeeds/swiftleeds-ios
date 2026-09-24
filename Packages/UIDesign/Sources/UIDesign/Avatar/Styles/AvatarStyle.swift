import SwiftUI

/// A type that applies a custom appearance to all avatars within a view
/// hierarchy.
///
/// To configure the current avatar style for a view hierarchy, use the
/// ``SwiftUI/View/avatarStyle(_:)`` modifier.
///
/// ```swift
/// struct SquareAvatarStyle: AvatarStyle {
///     func makeBody(configuration: Configuration) -> some View {
///         configuration.content
///             .frame(configuration.size)
///             .overlay(alignment: .topTrailing) { configuration.status }
///     }
/// }
/// ```
///
/// The status arrives drawn, so a style places it and nothing more. A style
/// that leaves it out shows no status at all.
///
/// A style may read the environment, so it can answer the color scheme and the
/// Dynamic Type size.
public protocol AvatarStyle: DynamicProperty {
    /// A view that represents the body of an avatar.
    associatedtype Body: View

    /// The properties of an avatar.
    typealias Configuration = AvatarStyleConfiguration

    /// Creates a view that represents the body of an avatar.
    ///
    /// The system calls this method for each `Avatar` instance in a view
    /// hierarchy where this style is the current avatar style.
    ///
    /// - Parameter configuration: The properties of the avatar.
    @ViewBuilder @MainActor
    func makeBody(configuration: Configuration) -> Body
}
