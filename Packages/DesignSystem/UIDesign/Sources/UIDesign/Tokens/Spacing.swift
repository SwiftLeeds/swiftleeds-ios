import CoreGraphics

/// The space between elements, on a four point grid.
public struct Spacing: Equatable, Hashable, Sendable {
    fileprivate let points: CGFloat

    init(_ points: CGFloat) {
        self.points = points
    }
}

extension Spacing {
    public static let xxSmall = Spacing(2)
    public static let xSmall = Spacing(4)
    public static let small = Spacing(8)
    public static let medium = Spacing(12)
    public static let large = Spacing(16)
    public static let xLarge = Spacing(24)
    public static let xxLarge = Spacing(32)
}

extension CGFloat {
    /// Creates a length from a space.
    public init(_ spacing: Spacing) {
        self = spacing.points
    }
}
