import CoreGraphics
import Testing
import UIDesign

/// Tests for the scale of ``BorderWidthLevel``.
struct BorderWidthLevelTests {
    /// Checks that the scale holds half a point, one point and one and a half points.
    @Test
    func whenLevelsAreListed_shouldReturnHalfOneAndOneAndAHalfPoints() {
        let widths = BorderWidthLevel.allCases.map(CGFloat.init)
        #expect(widths == [0.5, 1, 1.5])
    }
}
