import CoreGraphics

/// The space between elements, on a four point grid.
public struct Spacing: Equatable, Hashable, Sendable {
    fileprivate let points: CGFloat

    init(_ points: CGFloat) {
        self.points = points
    }
}

public extension Spacing {
    static let xxSmall = Spacing(2)
    static let xSmall = Spacing(4)
    static let small = Spacing(8)
    static let medium = Spacing(12)
    static let large = Spacing(16)
    static let xLarge = Spacing(24)
    static let xxLarge = Spacing(32)
}

public extension CGFloat {
    /// Creates a length from a space.
    init(_ spacing: Spacing) {
        self = spacing.points
    }
}
