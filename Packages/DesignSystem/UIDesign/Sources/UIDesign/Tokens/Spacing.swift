import CoreGraphics

/// The space between or around elements, named by size.
public struct Spacing: Equatable, Hashable, Sendable {
    /// The space, in points.
    fileprivate let points: CGFloat

    /// Creates a space of a number of points.
    ///
    /// - Parameter points: The space, in points.
    private init(_ points: CGFloat) {
        self.points = points
    }
}

extension Spacing {
    // swiftlint:disable no_magic_numbers identifier_name - token values under short size names
    /// The smallest space, such as between the lines of one block of text.
    public static let xxs = Spacing(2)

    /// An extra small space, such as between a symbol and its name in a badge.
    public static let xs = Spacing(4)

    /// A small space, such as between badges in a row.
    public static let sm = Spacing(8)

    /// A medium space, such as between an icon and its text.
    public static let md = Spacing(12)

    /// A large space, such as between a card's edge and its content.
    public static let lg = Spacing(16)

    /// An extra large space, such as between two sections.
    public static let xl = Spacing(24)

    /// The largest space, such as between the columns of a wide layout.
    public static let xxl = Spacing(32)
    // swiftlint:enable no_magic_numbers identifier_name
}

extension CGFloat {
    /// Creates a length in points from a space.
    ///
    /// - Parameter spacing: The space to convert.
    package init(_ spacing: Spacing) {
        self = spacing.points
    }
}
