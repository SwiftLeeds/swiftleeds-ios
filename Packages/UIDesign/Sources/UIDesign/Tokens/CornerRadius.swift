import CoreGraphics

/// The radius of a rounded corner.
public struct CornerRadius: Equatable, Hashable, Sendable {
    fileprivate let points: CGFloat

    init(_ points: CGFloat) {
        self.points = points
    }
}

public extension CornerRadius {
    static let none = CornerRadius(0)
    static let small = CornerRadius(8)
    static let medium = CornerRadius(12)
    static let large = CornerRadius(16)
    static let xLarge = CornerRadius(24)

    /// A fully rounded end. `RoundedRectangle` clamps this to half the shorter side.
    static let full = CornerRadius(.infinity)
}

public extension CGFloat {
    /// Creates a length from a corner radius.
    init(_ radius: CornerRadius) {
        self = radius.points
    }
}
