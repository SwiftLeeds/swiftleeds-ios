import SwiftUI

/// An avatar style that draws a rounded square, with any status on its lower
/// trailing corner.
///
/// You can also use ``AvatarStyle/rounded`` to construct this style.
public struct RoundedAvatarStyle: AvatarStyle {
    /// Creates a rounded avatar style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        ClippedAvatar(
            configuration: configuration,
            shape: RoundedRectangle(cornerRadius: .tile),
        )
    }
}

extension AvatarStyle where Self == RoundedAvatarStyle {
    /// An avatar style that draws a rounded square, with any status on its
    /// lower trailing corner.
    public static var rounded: RoundedAvatarStyle { RoundedAvatarStyle() }
}
