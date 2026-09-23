import SwiftUI

/// A type that draws an ``Avatar``.
///
/// Write one to give avatars a shape of your own, then set it with
/// ``SwiftUI/View/avatarStyle(_:)``.
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
/// The status arrives drawn, so a style places it and nothing more. Leave it out and the avatar
/// shows no status at all.
///
/// A style may read the environment, so it can answer the appearance and the text size.
public protocol AvatarStyle: DynamicProperty {
    associatedtype Body: View

    typealias Configuration = AvatarStyleConfiguration

    /// Draws one avatar.
    @ViewBuilder @MainActor
    func makeBody(configuration: Configuration) -> Body
}
