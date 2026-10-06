import SwiftUI

extension EnvironmentValues {
    /// The avatar style applied to the view hierarchy.
    @Entry public var avatarStyle: any AvatarStyle = .automatic
}

extension View {
    /// Sets the style for avatars within this view.
    ///
    /// ```swift
    /// VStack {
    ///     Avatar(url: first.photoURL)
    ///     Avatar(url: second.photoURL)
    /// }
    /// .avatarStyle(.rounded)
    /// ```
    ///
    /// - Parameter style: The avatar style to apply.
    public func avatarStyle(_ style: some AvatarStyle) -> some View {
        environment(\.avatarStyle, style)
    }
}
