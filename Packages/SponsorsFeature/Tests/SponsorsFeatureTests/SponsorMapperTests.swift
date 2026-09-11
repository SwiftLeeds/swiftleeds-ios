import Foundation
import SponsorsFeature
import Testing

@Suite struct SponsorMapperTests {
    private let sut = SponsorMapper.live

    @Test func whenResponseIsWellFormed_shouldReturnEverySponsor() throws {
        let data = SponsorsJSON.list(
            SponsorsJSON.sponsor(id: "a", name: "CodeMagic", level: "platinum"),
            SponsorsJSON.sponsor(id: "b", name: "Screenshotbot", level: "gold")
        )

        let sponsors = try sut.map(data, try .fixture(statusCode: 200))

        #expect(sponsors.map(\.id) == ["a", "b"])
        #expect(sponsors.map(\.level) == [.platinum, .gold])
        #expect(sponsors.first?.name == "CodeMagic")
    }

    @Test func whenSponsorCarriesJobs_shouldReturnThem() throws {
        let data = SponsorsJSON.list(
            SponsorsJSON.sponsor(jobs: "[\(SponsorsJSON.job(title: "Senior iOS Engineer"))]")
        )

        let sponsors = try sut.map(data, try .fixture(statusCode: 200))

        #expect(sponsors.first?.jobs.map(\.title) == ["Senior iOS Engineer"])
    }

    // MARK: - A bad link costs a link, not the list

    @Test func whenLogoURLIsUnusable_shouldReturnSponsorWithoutLogo() throws {
        let data = SponsorsJSON.list(SponsorsJSON.sponsor(image: ""))

        let sponsors = try sut.map(data, try .fixture(statusCode: 200))

        #expect(sponsors.count == 1)
        #expect(sponsors.first?.logoURL == nil)
    }

    @Test func whenWebsiteURLIsEmpty_shouldReturnSponsorWithoutWebsite() throws {
        let data = SponsorsJSON.list(SponsorsJSON.sponsor(url: ""))

        let sponsors = try sut.map(data, try .fixture(statusCode: 200))

        #expect(sponsors.count == 1)
        #expect(sponsors.first?.websiteURL == nil)
    }

    // MARK: - A level we do not sell is a refusal

    @Test func whenLevelIsUnknown_shouldThrowUnknownLevel() throws {
        let data = SponsorsJSON.list(SponsorsJSON.sponsor(name: "Bronze Co", level: "bronze"))
        let response = try HTTPURLResponse.fixture(statusCode: 200)

        #expect(throws: SponsorMapper.ResponseError.self) {
            try sut.map(data, response)
        }
    }

    @Test func whenLevelIsUnknown_shouldNameTheSponsorAndTheLevel() throws {
        let data = SponsorsJSON.list(SponsorsJSON.sponsor(name: "Bronze Co", level: "bronze"))
        let response = try HTTPURLResponse.fixture(statusCode: 200)

        do {
            _ = try sut.map(data, response)
            Issue.record("Expected an unknown level to be refused")
        } catch {
            guard case let .unknownLevel(detail) = error else {
                Issue.record("Expected .unknownLevel, got \(error)")
                return
            }
            #expect(detail.sponsor == "Bronze Co")
            #expect(detail.level == "bronze")
        }
    }

    // MARK: - Everything else is a refusal too

    @Test func whenBodyIsNotTheExpectedShape_shouldThrowCouldNotDecode() throws {
        let response = try HTTPURLResponse.fixture(statusCode: 200)

        #expect(throws: SponsorMapper.ResponseError.self) {
            try sut.map(Data("{\"unexpected\":true}".utf8), response)
        }
    }

    @Test(arguments: [404, 500])
    func whenStatusIsNotOK_shouldThrowUnexpectedStatus(statusCode: Int) throws {
        let data = SponsorsJSON.list(SponsorsJSON.sponsor())
        let response = try HTTPURLResponse.fixture(statusCode: statusCode)

        #expect(throws: SponsorMapper.ResponseError.self) {
            try sut.map(data, response)
        }
    }
}
