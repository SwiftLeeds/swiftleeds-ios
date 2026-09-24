import SwiftUI

/// An avatar style that draws a rounded square, with any status on its lower
/// trailing corner.
///
/// You can also use ``AvatarStyle/rounded`` to construct this style.
public struct RoundedAvatarStyle: AvatarStyle {
    /// The radius of each corner.
    private let cornerRadius: CornerRadius

    /// Creates a rounded avatar style.
    ///
    /// - Parameter cornerRadius: The radius of each corner. The default is
    ///   ``CornerRadius/medium``.
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
    /// An avatar style that draws a rounded square, with any status on its
    /// lower trailing corner.
    static var rounded: RoundedAvatarStyle { RoundedAvatarStyle() }

    /// An avatar style that draws a rounded square with a corner radius of
    /// your own.
    ///
    /// - Parameter cornerRadius: The radius of each corner.
    static func rounded(cornerRadius: CornerRadius) -> RoundedAvatarStyle {
        RoundedAvatarStyle(cornerRadius: cornerRadius)
    }
}
