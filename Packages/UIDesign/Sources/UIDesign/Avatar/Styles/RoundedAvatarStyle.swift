import SwiftUI

/// Draws an avatar as a rounded square, with any status on its lower trailing corner.
public struct RoundedAvatarStyle: AvatarStyle {
    private let cornerRadius: CornerRadius

    /// Creates the style.
    ///
    /// - Parameter cornerRadius: The radius of each corner.
    public init(cornerRadius: CornerRadius = .medium) {
        self.cornerRadius = cornerRadius
    }

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        ClippedAvatar(
            configuration: configuration,
            shape: .rect(cornerRadius: CGFloat(cornerRadius))
        )
    }
}

public extension AvatarStyle where Self == RoundedAvatarStyle {
    /// A rounded square.
    static var rounded: RoundedAvatarStyle { RoundedAvatarStyle() }

    /// A rounded square with a corner radius of your own.
    static func rounded(cornerRadius: CornerRadius) -> RoundedAvatarStyle {
        RoundedAvatarStyle(cornerRadius: cornerRadius)
    }
}
