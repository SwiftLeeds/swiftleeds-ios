import CoreGraphics

/// The side of the square an icon draws in.
///
/// Each value is a base size at the default text size. Pass it through `@ScaledMetric` so the
/// frame grows with the text beside it. A fixed frame clips the symbol at the accessibility
/// text sizes.
public struct IconSize: Equatable, Hashable, Sendable {
    fileprivate let points: CGFloat

    init(_ points: CGFloat) {
        self.points = points
    }
}

public extension IconSize {
    static let xSmall = IconSize(12)
    static let small = IconSize(16)
    static let medium = IconSize(20)
    static let large = IconSize(24)
    static let xLarge = IconSize(32)

    /// Also the smallest comfortable touch target.
    static let xxLarge = IconSize(44)
}

public extension CGFloat {
    /// Creates a length from an icon size.
    init(_ size: IconSize) {
        self = size.points
    }
}
