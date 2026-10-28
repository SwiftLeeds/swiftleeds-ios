import CoreGraphics

/// The width of a drawn line, in whole points from Apple's floor of two.
package struct LineWidthLevel: Equatable, Hashable, Sendable {
    /// The width, in whole points.
    fileprivate let points: Int

    /// Creates a level from a number of points.
    ///
    /// - Parameter points: The width, in whole points.
    private init(points: Int) {
        self.points = points
    }
}

extension LineWidthLevel {
    // swiftlint:disable no_magic_numbers - each number here is the value its name defines
    /// The thinnest level: a line of 2 points.
    package static let points2 = LineWidthLevel(points: 2)

    /// The level of 3 points.
    package static let points3 = LineWidthLevel(points: 3)

    /// The level of 4 points.
    package static let points4 = LineWidthLevel(points: 4)

    /// The level of 5 points.
    package static let points5 = LineWidthLevel(points: 5)

    /// The level of 6 points.
    package static let points6 = LineWidthLevel(points: 6)

    /// The level of 7 points.
    package static let points7 = LineWidthLevel(points: 7)

    /// The thickest level: a line of 8 points.
    package static let points8 = LineWidthLevel(points: 8)
    // swiftlint:enable no_magic_numbers
}

extension LineWidthLevel: CaseIterable {
    /// Every level, from thin to thick.
    package static let allCases: [LineWidthLevel] = [
        .points2,
        .points3,
        .points4,
        .points5,
        .points6,
        .points7,
        .points8,
    ]
}

extension CGFloat {
    /// Creates a length from a line width level.
    ///
    /// - Parameter level: The level to read.
    package init(_ level: LineWidthLevel) {
        self = CGFloat(level.points)
    }
}
