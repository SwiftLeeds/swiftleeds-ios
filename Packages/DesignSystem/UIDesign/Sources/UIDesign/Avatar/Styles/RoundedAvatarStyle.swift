import SwiftUI

/// An avatar style that draws a rounded square, with any status on its lower
/// trailing corner.
///
/// At large sizes and large text sizes, the status can draw outside the avatar's frame.
///
/// You can also use ``AvatarStyle/rounded`` to construct this style.
public struct RoundedAvatarStyle: AvatarStyle {
    /// Creates a rounded avatar style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: .tile)
        ClippedAvatar(
            configuration: configuration,
            shape: shape,
            statusInsetLimit: shape.cornerSize.width,
        )
    }
}

extension AvatarStyle where Self == RoundedAvatarStyle {
    /// An avatar style that draws a rounded square, with any status on its
    /// lower trailing corner.
    public static var rounded: RoundedAvatarStyle { RoundedAvatarStyle() }
}
