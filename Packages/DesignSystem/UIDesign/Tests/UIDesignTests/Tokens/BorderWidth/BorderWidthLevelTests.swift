import CoreGraphics
import Testing
import UIDesign

/// Tests for the scale of ``BorderWidthLevel``.
struct BorderWidthLevelTests {
    /// Checks that the scale holds zero, half a point, one point and one and a half points.
    @Test
    func whenLevelsAreListed_shouldReturnZeroHalfOneAndOneAndAHalfPoints() {
        let widths = BorderWidthLevel.allCases.map(CGFloat.init)
        #expect(widths == [0, 0.5, 1, 1.5])
    }
}
