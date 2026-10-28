import Testing
import UIDesign

/// Tests for the scale of ``OpacityLevel``.
struct OpacityLevelTests {
    /// The distance between two levels, in percent.
    private static let step = 4

    /// The largest level, in percent.
    private static let whole = 100

    /// Checks that the scale runs from clear to opaque in steps of four percent.
    @Test
    func whenLevelsAreListed_shouldReturnEveryFourPercentFromZeroToOneHundred() {
        let levels = OpacityLevel.allCases.map(Double.init)
        let expected = stride(from: 0, through: Self.whole, by: Self.step).map {
            Double($0) / Double(Self.whole)
        }
        #expect(levels == expected)
    }
}
