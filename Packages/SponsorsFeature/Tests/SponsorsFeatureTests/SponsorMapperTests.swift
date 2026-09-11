import Foundation
import SponsorsFeature
import Testing

@Suite struct SponsorMapperTests {
    private let sut = SponsorMapper.live

    @Test func whenListHasSponsors_shouldMapEveryOne() throws {
        let list = SponsorListDTO(data: [
            .fixture(id: "a", name: "CodeMagic", sponsorLevel: "platinum"),
            .fixture(id: "b", name: "Screenshotbot", sponsorLevel: "gold"),
        ])

        let sponsors = try sut.map(list)

        #expect(sponsors.rankedLevels == [.platinum, .gold])
        #expect(sponsors.sponsors(at: .platinum).map(\.id) == [SponsorID("a")])
        #expect(sponsors.sponsors(at: .platinum).first?.name == "CodeMagic")
        #expect(sponsors.sponsors(at: .platinum).first?.subtitle == "CI/CD for mobile dev teams")
    }

    @Test func whenListIsEmpty_shouldMapToNoSponsors() throws {
        #expect(try sut.map(SponsorListDTO(data: [])).isEmpty)
    }

    @Test func whenLevelsArriveOutOfOrder_shouldRankThem() throws {
        let list = SponsorListDTO(data: [
            .fixture(id: "a", sponsorLevel: "silver"),
            .fixture(id: "b", sponsorLevel: "platinum"),
            .fixture(id: "c", sponsorLevel: "gold"),
        ])

        #expect(try sut.map(list).rankedLevels == [.platinum, .gold, .silver])
    }

    @Test func whenSponsorCarriesJobs_shouldMapThem() throws {
        let list = SponsorListDTO(data: [
            .fixture(jobs: [.fixture(title: "Senior iOS Engineer", location: "Leeds")]),
        ])

        let jobs = try #require(sut.map(list).sponsors(at: .platinum).first?.jobs)

        #expect(jobs.map(\.title) == ["Senior iOS Engineer"])
        #expect(jobs.first?.location == "Leeds")
    }

    // MARK: - A missing link costs a link, not the list

    @Test func whenLogoIsMissing_shouldMapSponsorWithoutLogo() throws {
        let list = SponsorListDTO(data: [.fixture(image: "")])

        let sponsor = try #require(sut.map(list).sponsors(at: .platinum).first)

        #expect(sponsor.logoURL == nil)
    }

    @Test func whenWebsiteIsMissing_shouldMapSponsorWithoutWebsite() throws {
        let list = SponsorListDTO(data: [.fixture(url: "")])

        let sponsor = try #require(sut.map(list).sponsors(at: .platinum).first)

        #expect(sponsor.websiteURL == nil)
    }

    @Test func whenJobLinkIsMissing_shouldMapJobWithoutLink() throws {
        let list = SponsorListDTO(data: [.fixture(jobs: [.fixture(url: "")])])

        let job = try #require(sut.map(list).sponsors(at: .platinum).first?.jobs.first)

        #expect(job.url == nil)
    }

    // MARK: - A level we do not sell is a refusal

    @Test func whenLevelIsUnknown_shouldRefuseTheList() throws {
        let list = SponsorListDTO(data: [.fixture(name: "Bronze Co", sponsorLevel: "bronze")])

        #expect(throws: SponsorMapper.MappingError.self) {
            try sut.map(list)
        }
    }

    @Test func whenLevelIsUnknown_shouldNameTheSponsorTheFieldAndTheValue() throws {
        let list = SponsorListDTO(data: [.fixture(name: "Bronze Co", sponsorLevel: "bronze")])

        do {
            _ = try sut.map(list)
            Issue.record("Expected an unknown level to be refused")
        } catch {
            #expect(error.sponsor == "Bronze Co")
            #expect(error.field == .sponsorLevel)
            #expect(error.value == "bronze")
        }
    }

    @Test func whenOneLevelIsUnknown_shouldRefuseEvenTheReadableSponsors() throws {
        let list = SponsorListDTO(data: [
            .fixture(id: "a", sponsorLevel: "platinum"),
            .fixture(id: "b", sponsorLevel: "bronze"),
        ])

        #expect(throws: SponsorMapper.MappingError.self) {
            try sut.map(list)
        }
    }
}
