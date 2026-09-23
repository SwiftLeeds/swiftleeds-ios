import CoreGraphics

/// The width of a border or a divider.
public struct BorderWidth: Equatable, Hashable, Sendable {
    fileprivate let points: CGFloat

    init(_ points: CGFloat) {
        self.points = points
    }
}

public extension BorderWidth {
    /// A hairline. Draws as one device pixel at a display scale of two or more.
    static let thin = BorderWidth(0.5)

    static let medium = BorderWidth(1)
    static let thick = BorderWidth(2)
}

public extension CGFloat {
    /// Creates a length from a border width.
    init(_ width: BorderWidth) {
        self = width.points
    }
}
