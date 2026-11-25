#if os(macOS)
import Testing
import UIDesign

struct QuietZoneTests {
    @Test
    func whenMarginIsNarrowerThanRequired_shouldReturnTheDifference() {
        let sut = BarcodeImage.QuietZone(modules: 1)
        let required = BarcodeImage.QuietZone(modules: 4)

        let missing = sut.missing(toReach: required)

        #expect(missing == BarcodeImage.QuietZone(modules: 3))
    }

    @Test
    func whenMarginEqualsRequired_shouldReturnNoZone() {
        let sut = BarcodeImage.QuietZone(modules: 2)
        let required = BarcodeImage.QuietZone(modules: 2)

        let missing = sut.missing(toReach: required)

        #expect(missing == BarcodeImage.QuietZone(modules: 0))
    }

    @Test
    func whenMarginIsWiderThanRequired_shouldReturnNoZone() {
        let sut = BarcodeImage.QuietZone(modules: 3)
        let required = BarcodeImage.QuietZone(modules: 2)

        let missing = sut.missing(toReach: required)

        #expect(missing == BarcodeImage.QuietZone(modules: 0))
    }
}
#endif
