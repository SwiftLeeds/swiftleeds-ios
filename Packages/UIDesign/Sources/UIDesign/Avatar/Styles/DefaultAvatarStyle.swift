import SwiftUI

/// Draws an avatar as a circle, with any status on its lower trailing edge.
public struct DefaultAvatarStyle: AvatarStyle {
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        ClippedAvatar(configuration: configuration, shape: .circle)
    }
}

public extension AvatarStyle where Self == DefaultAvatarStyle {
    /// A circle, which is how an avatar draws unless a style says otherwise.
    static var automatic: DefaultAvatarStyle { DefaultAvatarStyle() }
}
