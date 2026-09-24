import CoreGraphics

/// The diameter of an avatar, at the default text size.
///
/// ``Avatar`` grows it with the text size for you.
public struct AvatarSize: Equatable, Hashable, Sendable {
    /// The diameter in points.
    fileprivate let points: CGFloat

    /// Creates a size.
    ///
    /// - Parameter points: The diameter in points.
    init(_ points: CGFloat) {
        self.points = points
    }
}

public extension AvatarSize {
    /// An avatar in a dense row, or in a group of them.
    static let small = AvatarSize(28)

    /// An avatar in a list row. This is the size a nameplate's row uses.
    static let medium = AvatarSize(40)

    /// An avatar in a heading that names a screen's subject.
    static let large = AvatarSize(56)

    /// An avatar that is the screen's subject, such as on a profile.
    static let xLarge = AvatarSize(80)
}

public extension CGFloat {
    /// Creates a length from an avatar size.
    init(_ size: AvatarSize) {
        self = size.points
    }
}

extension AvatarSize {
    /// Returns this size multiplied by a text scale.
    ///
    /// The result is not one of the named values.
    func scaled(by scale: CGFloat) -> AvatarSize {
        AvatarSize(points * scale)
    }
}
