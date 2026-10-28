import CoreGraphics

/// The width of an edge, in points.
package struct BorderWidthLevel: Equatable, Hashable, Sendable {
    /// The width, in points.
    fileprivate let points: CGFloat

    /// Creates a level from a number of points.
    ///
    /// - Parameter points: The width, in points.
    private init(points: CGFloat) {
        self.points = points
    }
}

extension BorderWidthLevel {
    // swiftlint:disable no_magic_numbers - each number here is the value its name defines
    /// The thinnest level: an edge of half a point.
    package static let thin = BorderWidthLevel(points: 0.5)

    /// The level of 1 point.
    package static let medium = BorderWidthLevel(points: 1)

    /// The thickest level: an edge of 1.5 points.
    package static let thick = BorderWidthLevel(points: 1.5)
    // swiftlint:enable no_magic_numbers
}

extension BorderWidthLevel: CaseIterable {
    /// Every level, from thin to thick.
    package static let allCases: [BorderWidthLevel] = [
        .thin,
        .medium,
        .thick,
    ]
}

extension CGFloat {
    /// Creates a length from a border width level.
    ///
    /// - Parameter level: The level to read.
    package init(_ level: BorderWidthLevel) {
        self = level.points
    }
}
