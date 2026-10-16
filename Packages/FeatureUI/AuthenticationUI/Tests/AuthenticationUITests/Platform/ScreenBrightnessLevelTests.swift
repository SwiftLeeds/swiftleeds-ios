import AuthenticationUI
import Testing

@Suite struct ScreenBrightnessLevelTests {
    @Test(arguments: [0, 0.25, 0.5, 1])
    func whenLevelIsWithinRange_shouldKeepIt(_ value: Double) {
        let level = ScreenBrightness.Level(value)

        #expect(Double(level) == value)
    }

    @Test(arguments: [1.0001, 2, 100, .infinity])
    func whenLevelIsAboveRange_shouldPinToBrightest(_ value: Double) {
        let level = ScreenBrightness.Level(value)

        #expect(level == .brightest)
    }

    @Test(arguments: [-0.0001, -1, -100, -Double.infinity])
    func whenLevelIsBelowRange_shouldPinToDimmest(_ value: Double) {
        let level = ScreenBrightness.Level(value)

        #expect(Double(level) == 0)
    }

    @Test func whenLevelIsNotANumber_shouldPinToDimmest() {
        let level = ScreenBrightness.Level(.nan)

        #expect(Double(level) == 0)
    }

    @Test func whenWrittenAsALiteral_shouldMatchTheSameValueSpelledOut() {
        let literal: ScreenBrightness.Level = 0.4

        #expect(literal == ScreenBrightness.Level(0.4))
    }

    @Test func whenBrightest_shouldBeTheTopOfTheRange() {
        #expect(Double(ScreenBrightness.Level.brightest) == 1)
    }
}
