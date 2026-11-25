#if os(macOS)
import Testing
import UIDesign

struct QuietZoneTests {
    @Test
    func whenMarginIsNarrowerThanRequired_shouldReturnTheDifference() {
        let margin = BarcodeImage.QuietZone(modules: 1)
        let required = BarcodeImage.QuietZone(modules: 4)

        let sut = margin.missing(toReach: required)

        #expect(sut == BarcodeImage.QuietZone(modules: 3))
    }

    @Test
    func whenMarginEqualsRequired_shouldReturnNoZone() {
        let margin = BarcodeImage.QuietZone(modules: 2)
        let required = BarcodeImage.QuietZone(modules: 2)

        let sut = margin.missing(toReach: required)

        #expect(sut == BarcodeImage.QuietZone(modules: 0))
    }

    @Test
    func whenMarginIsWiderThanRequired_shouldReturnNoZone() {
        let margin = BarcodeImage.QuietZone(modules: 3)
        let required = BarcodeImage.QuietZone(modules: 2)

        let sut = margin.missing(toReach: required)

        #expect(sut == BarcodeImage.QuietZone(modules: 0))
    }
}
#endif
