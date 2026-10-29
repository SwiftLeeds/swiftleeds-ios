import CoreGraphics

/// The space between elements, on a four point grid.
public struct Spacing: Equatable, Hashable, Sendable {
    fileprivate let points: CGFloat

    init(_ points: CGFloat) {
        self.points = points
    }
}

extension Spacing {
    // swiftlint:disable no_magic_numbers identifier_name - token values under short size names
    public static let xxs = Spacing(2)
    public static let xs = Spacing(4)
    public static let sm = Spacing(8)
    public static let md = Spacing(12)
    public static let lg = Spacing(16)
    public static let xl = Spacing(24)
    public static let xxl = Spacing(32)
    // swiftlint:enable no_magic_numbers identifier_name
}

extension CGFloat {
    /// Creates a length from a space.
    public init(_ spacing: Spacing) {
        self = spacing.points
    }
}
