import SwiftUI

/// The default avatar style, which draws a circle with any status on its lower
/// trailing edge.
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

public extension AvatarStyle where Self == DefaultAvatarStyle {
    /// The default avatar style, which draws a circle with any status on its
    /// lower trailing edge.
    static var automatic: DefaultAvatarStyle { DefaultAvatarStyle() }
}
