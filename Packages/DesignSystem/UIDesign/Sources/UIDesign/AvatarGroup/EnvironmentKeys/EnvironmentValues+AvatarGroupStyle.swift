import SwiftUI

extension EnvironmentValues {
    /// The avatar group style applied to the view hierarchy.
    @Entry public var avatarGroupStyle: any AvatarGroupStyle = .automatic
}

extension View {
    /// Sets the style for avatar groups within this view.
    ///
    /// ```swift
    /// VStack {
    ///     AvatarGroup { speakers }
    ///     AvatarGroup { attendees }
    /// }
    /// .avatarGroupStyle(StackedAvatarGroupStyle())
    /// ```
    ///
    /// - Parameter style: The avatar group style to apply.
    /// - Returns: A view that uses the given style for the avatar groups within it.
    public func avatarGroupStyle(_ style: some AvatarGroupStyle) -> some View {
        environment(\.avatarGroupStyle, style)
    }
}
