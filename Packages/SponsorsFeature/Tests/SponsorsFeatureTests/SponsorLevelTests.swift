import SponsorsFeature
import Testing

@Suite struct SponsorLevelTests {
    @Test func whenListingCases_shouldRankBestFirst() {
        #expect(SponsorLevel.allCases == [.platinum, .gold, .silver])
    }

    @Test(arguments: [
        ("platinum", SponsorLevel.platinum),
        ("gold", SponsorLevel.gold),
        ("silver", SponsorLevel.silver),
    ])
    func whenParsingWireValue_shouldReturnLevel(value: String, expected: SponsorLevel) {
        #expect(SponsorLevel(rawValue: value) == expected)
    }

    @Test func whenParsingUnknownWireValue_shouldReturnNil() {
        #expect(SponsorLevel(rawValue: "bronze") == nil)
    }
}
