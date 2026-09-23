import SwiftUI

/// Draws an avatar as a rounded square, with any status on its lower trailing corner.
public struct RoundedAvatarStyle: AvatarStyle {
    private let cornerRadius: CGFloat

    /// Creates the style.
    ///
    /// - Parameter cornerRadius: A radius from ``CornerRadius``.
    public init(cornerRadius: CGFloat = CornerRadius.medium) {
        self.cornerRadius = cornerRadius
    }

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        ClippedAvatar(configuration: configuration, shape: .rect(cornerRadius: cornerRadius))
    }
}

public extension AvatarStyle where Self == RoundedAvatarStyle {
    /// A rounded square.
    static var rounded: RoundedAvatarStyle { RoundedAvatarStyle() }

    /// A rounded square with a corner radius of your own.
    static func rounded(cornerRadius: CGFloat) -> RoundedAvatarStyle {
        RoundedAvatarStyle(cornerRadius: cornerRadius)
    }
}
