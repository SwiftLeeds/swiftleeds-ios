import CoreGraphics
import Testing
import UIDesign

/// Tests for the scale of ``Spacing``.
struct SpacingTests {
    /// Checks that the scale runs 2, 4, 8, 12, 16, 24 and 32 points, from the smallest space.
    @Test
    func whenSpacesAreListedFromSmallest_shouldReturnTheGridValues() {
        let sut: [Spacing] = [.xxs, .xs, .sm, .md, .lg, .xl, .xxl]
        #expect(sut.map(CGFloat.init) == [2, 4, 8, 12, 16, 24, 32])
    }
}
