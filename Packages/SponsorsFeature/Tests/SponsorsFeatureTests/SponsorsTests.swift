import SponsorsFeature
import Testing

@Suite struct SponsorsTests {
    @Test func whenGroupingMixedLevels_shouldRankBestFirst() {
        let sponsors = Sponsors([
            .fixture(id: "a", level: .silver),
            .fixture(id: "b", level: .platinum),
            .fixture(id: "c", level: .gold),
        ])

        #expect(sponsors.rankedLevels == [.platinum, .gold, .silver])
    }

    @Test func whenALevelHasNoSponsors_shouldOmitIt() {
        let sponsors = Sponsors([
            .fixture(id: "a", level: .platinum),
            .fixture(id: "b", level: .silver),
        ])

        #expect(sponsors.rankedLevels == [.platinum, .silver])
        #expect(sponsors.sponsors(at: .gold).isEmpty)
    }

    @Test func whenGrouping_shouldKeepEverySponsorAtItsOwnLevel() {
        let first = Sponsor.fixture(id: "a", level: .gold)
        let second = Sponsor.fixture(id: "b", level: .gold)
        let other = Sponsor.fixture(id: "c", level: .platinum)

        let sponsors = Sponsors([first, second, other])

        #expect(sponsors.sponsors(at: .gold) == [first, second])
        #expect(sponsors.sponsors(at: .platinum) == [other])
    }

    /// A conference with no sponsors yet is a real state, not a failure.
    @Test func whenNoSponsors_shouldBeEmpty() {
        let sponsors = Sponsors([])

        #expect(sponsors.isEmpty)
        #expect(sponsors.rankedLevels.isEmpty)
    }

    @Test func whenAnySponsor_shouldNotBeEmpty() {
        #expect(Sponsors([.fixture()]).isEmpty == false)
    }
}
