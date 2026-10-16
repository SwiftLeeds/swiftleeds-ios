import CoreGraphics

/// The width of a border or a divider.
public struct BorderWidth: Equatable, Hashable, Sendable {
    fileprivate let points: CGFloat

    init(_ points: CGFloat) {
        self.points = points
    }
}

extension BorderWidth {
    /// A hairline. Draws as one device pixel at a display scale of two or more.
    public static let thin = BorderWidth(0.5)

    public static let medium = BorderWidth(1)
    public static let thick = BorderWidth(2)
}

extension CGFloat {
    /// Creates a length from a border width.
    public init(_ width: BorderWidth) {
        self = width.points
    }
}
