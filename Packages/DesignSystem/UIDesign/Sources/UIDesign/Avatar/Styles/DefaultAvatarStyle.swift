import SwiftUI

/// The default avatar style.
///
/// It draws a circle, with any status on its lower trailing edge, and an outline under
/// Increase Contrast.
///
/// You can also use ``AvatarStyle/automatic`` to construct this style.
public struct DefaultAvatarStyle: AvatarStyle {
    /// Creates a default avatar style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        ClippedAvatar(configuration: configuration, shape: .circle)
    }
}

extension AvatarStyle where Self == DefaultAvatarStyle {
    /// The default avatar style.
    public static var automatic: DefaultAvatarStyle { DefaultAvatarStyle() }
}
