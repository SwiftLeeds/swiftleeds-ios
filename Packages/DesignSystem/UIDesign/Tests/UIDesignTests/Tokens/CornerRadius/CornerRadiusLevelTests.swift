import CoreGraphics
import Testing
import UIDesign

/// Tests for the scale of ``CornerRadiusLevel``.
struct CornerRadiusLevelTests {
    /// Checks that the scale holds 8, 12, 16 and 24 points.
    @Test
    func whenLevelsAreListed_shouldReturnEightTwelveSixteenAndTwentyFourPoints() {
        let radii = CornerRadiusLevel.allCases.map(CGFloat.init)
        #expect(radii == [8, 12, 16, 24])
    }
}
