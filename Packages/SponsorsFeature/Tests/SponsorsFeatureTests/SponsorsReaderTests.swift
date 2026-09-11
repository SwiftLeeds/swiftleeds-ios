import Foundation
import SponsorsFeature
import Testing

@Suite struct SponsorsReaderTests {
    private let sut = SponsorsReader.live

    @Test func whenListHasSponsors_shouldReadEveryOne() throws {
        let list = SponsorListDTO(data: [
            .fixture(id: "a", name: "CodeMagic", sponsorLevel: "platinum"),
            .fixture(id: "b", name: "Screenshotbot", sponsorLevel: "gold"),
        ])

        let sponsors = try sut.read(list)

        #expect(sponsors.map(\.id) == [SponsorID("a"), SponsorID("b")])
        #expect(sponsors.map(\.level) == [.platinum, .gold])
        #expect(sponsors.first?.name == "CodeMagic")
        #expect(sponsors.first?.subtitle == "CI/CD for mobile dev teams")
    }

    @Test func whenListIsEmpty_shouldReadNoSponsors() throws {
        #expect(try sut.read(SponsorListDTO(data: [])).isEmpty)
    }

    @Test func whenSponsorCarriesJobs_shouldReadThem() throws {
        let list = SponsorListDTO(data: [
            .fixture(jobs: [.fixture(title: "Senior iOS Engineer", location: "Leeds")]),
        ])

        let jobs = try #require(sut.read(list).first?.jobs)

        #expect(jobs.map(\.title) == ["Senior iOS Engineer"])
        #expect(jobs.first?.location == "Leeds")
    }

    // MARK: - A missing link costs a link, not the list

    @Test func whenLogoIsMissing_shouldReadSponsorWithoutLogo() throws {
        let list = SponsorListDTO(data: [.fixture(image: "")])

        let sponsors = try sut.read(list)

        #expect(sponsors.count == 1)
        #expect(sponsors.first?.logoURL == nil)
    }

    @Test func whenWebsiteIsMissing_shouldReadSponsorWithoutWebsite() throws {
        let list = SponsorListDTO(data: [.fixture(url: "")])

        let sponsors = try sut.read(list)

        #expect(sponsors.count == 1)
        #expect(sponsors.first?.websiteURL == nil)
    }

    @Test func whenJobLinkIsMissing_shouldReadJobWithoutLink() throws {
        let list = SponsorListDTO(data: [.fixture(jobs: [.fixture(url: "")])])

        let job = try #require(sut.read(list).first?.jobs.first)

        #expect(job.url == nil)
    }

    // MARK: - A level we do not sell is a refusal

    @Test func whenLevelIsUnknown_shouldRefuseTheList() throws {
        let list = SponsorListDTO(data: [.fixture(name: "Bronze Co", sponsorLevel: "bronze")])

        #expect(throws: SponsorsReader.LevelError.self) {
            try sut.read(list)
        }
    }

    @Test func whenLevelIsUnknown_shouldNameTheSponsorAndTheLevel() throws {
        let list = SponsorListDTO(data: [.fixture(name: "Bronze Co", sponsorLevel: "bronze")])

        do {
            _ = try sut.read(list)
            Issue.record("Expected an unknown level to be refused")
        } catch {
            #expect(error.sponsor == "Bronze Co")
            #expect(error.level == "bronze")
        }
    }

    @Test func whenOneLevelIsUnknown_shouldRefuseEvenTheReadableSponsors() throws {
        let list = SponsorListDTO(data: [
            .fixture(id: "a", sponsorLevel: "platinum"),
            .fixture(id: "b", sponsorLevel: "bronze"),
        ])

        #expect(throws: SponsorsReader.LevelError.self) {
            try sut.read(list)
        }
    }
}
