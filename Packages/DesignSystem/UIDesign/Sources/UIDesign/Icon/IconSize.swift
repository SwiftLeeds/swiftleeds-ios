import CoreGraphics

/// The side of the square an icon draws in, at the default text size.
public struct IconSize: Equatable, Hashable, Sendable {
    fileprivate let points: CGFloat

    private init(_ points: CGFloat) {
        self.points = points
    }
}

extension IconSize {
    // swiftlint:disable no_magic_numbers - each number here is the value its name defines
    public static let xSmall = IconSize(12)
    public static let small = IconSize(16)
    public static let medium = IconSize(20)
    public static let large = IconSize(24)
    public static let xLarge = IconSize(32)

    /// Also the smallest comfortable touch target.
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
