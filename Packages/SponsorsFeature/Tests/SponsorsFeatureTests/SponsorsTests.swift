import SponsorsFeature
import Testing

@Suite struct SponsorsTests {
    @Test func whenGroupingMixedLevels_shouldRankBestFirst() {
        let sponsors = Sponsors([
            .fixture(id: SponsorID("a"), level: .silver),
            .fixture(id: SponsorID("b"), level: .platinum),
            .fixture(id: SponsorID("c"), level: .gold),
        ])

        #expect(sponsors.rankedLevels == [.platinum, .gold, .silver])
    }

    @Test func whenALevelHasNoSponsors_shouldOmitIt() {
        let sponsors = Sponsors([
            .fixture(id: SponsorID("a"), level: .platinum),
            .fixture(id: SponsorID("b"), level: .silver),
        ])

        #expect(sponsors.rankedLevels == [.platinum, .silver])
        #expect(sponsors.sponsors(at: .gold).isEmpty)
    }

    @Test func whenGrouping_shouldKeepEverySponsorAtItsOwnLevel() {
        let first = Sponsor.fixture(id: SponsorID("a"), level: .gold)
        let second = Sponsor.fixture(id: SponsorID("b"), level: .gold)
        let other = Sponsor.fixture(id: SponsorID("c"), level: .platinum)

        let sponsors = Sponsors([first, second, other])

        #expect(sponsors.sponsors(at: .gold) == [first, second])
        #expect(sponsors.sponsors(at: .platinum) == [other])
    }

    @Test func whenNoSponsors_shouldBeEmpty() {
        let sponsors = Sponsors([])

        #expect(sponsors.isEmpty)
        #expect(sponsors.rankedLevels.isEmpty)
    }

    @Test func whenAnySponsor_shouldNotBeEmpty() {
        #expect(Sponsors([.fixture()]).isEmpty == false)
    }
}
