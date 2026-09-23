import CoreGraphics

/// The diameter of an avatar.
///
/// Each named value is a base size at the default text size. ``Avatar`` grows it with the text
/// size for you.
public struct AvatarSize: Equatable, Hashable, Sendable {
    fileprivate let points: CGFloat

    init(_ points: CGFloat) {
        self.points = points
    }
}

public extension AvatarSize {
    static let small = AvatarSize(28)
    static let medium = AvatarSize(40)
    static let large = AvatarSize(56)
    static let xLarge = AvatarSize(80)
}

public extension CGFloat {
    /// Creates a length from an avatar size.
    init(_ size: AvatarSize) {
        self = size.points
    }
}

extension AvatarSize {
    // The text size has scaled this one, so it is not one of the named values.
    func scaled(by scale: CGFloat) -> AvatarSize {
        AvatarSize(points * scale)
    }
}
