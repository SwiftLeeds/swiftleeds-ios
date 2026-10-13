import CoreGraphics

/// The radius of a rounded corner.
public struct CornerRadius: Equatable, Hashable, Sendable {
    fileprivate let points: CGFloat

    init(_ points: CGFloat) {
        self.points = points
    }
}

extension CornerRadius {
    public static let none = CornerRadius(0)
    public static let small = CornerRadius(8)
    public static let medium = CornerRadius(12)
    public static let large = CornerRadius(16)
    public static let xLarge = CornerRadius(24)

    /// A fully rounded end. `RoundedRectangle` clamps this to half the shorter side.
    public static let full = CornerRadius(.infinity)
}

extension CGFloat {
    /// Creates a length from a corner radius.
    public init(_ radius: CornerRadius) {
        self = radius.points
    }
}
