import CoreGraphics
import Testing
import UIDesign

/// Tests for the scale of ``LineWidthLevel``.
struct LineWidthLevelTests {
    /// The thinnest level, in points.
    private static let first = 2

    /// The thickest level, in points.
    private static let last = 8

    /// Checks that the scale runs from two points to eight in whole points.
    @Test
    func whenLevelsAreListed_shouldReturnEveryWholePointFromTwoToEight() {
        let widths = LineWidthLevel.allCases.map(CGFloat.init)
        let expected = (Self.first...Self.last).map { CGFloat($0) }
        #expect(widths == expected)
    }
}
