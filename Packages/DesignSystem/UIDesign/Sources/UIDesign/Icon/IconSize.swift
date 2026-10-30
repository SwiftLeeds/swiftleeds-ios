import CoreGraphics

/// The side of the square an icon draws in, at the default text size.
public struct IconSize: Equatable, Hashable, Sendable {
    /// The side in points.
    fileprivate let points: CGFloat

    /// Creates a size.
    ///
    /// - Parameter points: The side in points.
    private init(_ points: CGFloat) {
        self.points = points
    }
}

extension IconSize {
    // swiftlint:disable no_magic_numbers - each number here is the value its name defines
    /// The smallest icon.
    public static let xSmall = IconSize(12)

    /// A small icon.
    public static let small = IconSize(16)

    /// A medium icon.
    public static let medium = IconSize(20)

    /// A large icon.
    public static let large = IconSize(24)

    /// An extra large icon.
    public static let xLarge = IconSize(32)

    /// The largest icon, the size of the smallest comfortable touch target.
    public static let xxLarge = IconSize(44)
    // swiftlint:enable no_magic_numbers
}

extension CGFloat {
    /// Creates a length from an icon size.
    ///
    /// - Parameter size: The icon size to convert.
    package init(_ size: IconSize) {
        self = size.points
    }
}
