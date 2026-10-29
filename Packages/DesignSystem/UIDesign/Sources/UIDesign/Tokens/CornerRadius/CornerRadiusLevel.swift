import CoreGraphics

/// The radius of a rounded corner, in points.
package struct CornerRadiusLevel: Equatable, Hashable, Sendable {
    /// The radius, in points.
    fileprivate let points: CGFloat

    /// Creates a level from a number of points.
    ///
    /// - Parameter points: The radius, in points.
    private init(points: CGFloat) {
        self.points = points
    }
}

extension CornerRadiusLevel {
    // swiftlint:disable no_magic_numbers - each number here is the value its name defines
    /// The level of 8 points.
    package static let points8 = CornerRadiusLevel(points: 8)

    /// The level of 12 points.
    package static let points12 = CornerRadiusLevel(points: 12)

    /// The level of 16 points.
    package static let points16 = CornerRadiusLevel(points: 16)

    /// The level of 24 points.
    package static let points24 = CornerRadiusLevel(points: 24)
    // swiftlint:enable no_magic_numbers
}

extension CornerRadiusLevel: CaseIterable {
    /// Every level, from the smallest radius to the largest.
    package static let allCases: [CornerRadiusLevel] = [
        .points8,
        .points12,
        .points16,
        .points24,
    ]
}

extension CGFloat {
    /// Creates a length from a corner radius level.
    ///
    /// - Parameter level: The level to read.
    package init(_ level: CornerRadiusLevel) {
        self = level.points
    }
}
