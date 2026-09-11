import Dependencies
import Foundation
import LogKit
import NetworkKit
import SponsorsFeature
import Testing

// Drives the composed `liveValue` with only the transport stubbed.
@Suite struct SponsorsRepositoryIntegrationTests {
    /// The mapper records the count, then the repository records the outcome. Two seams, two
    /// lines, and no third line from anywhere else.
    @Test func whenServerAnswersWell_shouldLogMappingThenFetch() async throws {
        let recorder = LogRecorder()
        let data = SponsorsJSON.list(SponsorsJSON.sponsor())

        _ = try await withDependencies {
            $0.log = recorder.log
            $0.httpClient = .responding(with: data, statusCode: 200)
        } operation: {
            try await SponsorsRepository.liveValue.fetch()
        }

        #expect(recorder.events.map(\.level) == [.debug, .info])
    }

    @Test func whenServerAnswersWell_shouldReturnSponsors() async throws {
        let data = SponsorsJSON.list(SponsorsJSON.sponsor(id: "a", level: "gold"))

        let sponsors = try await withDependencies {
            $0.httpClient = .responding(with: data, statusCode: 200)
        } operation: {
            try await SponsorsRepository.liveValue.fetch()
        }

        #expect(sponsors.rankedLevels == [.gold])
        #expect(sponsors.sponsors(at: .gold).map(\.id) == [SponsorID("a")])
    }

    @Test func whenRequestFails_shouldThrowCouldNotReachServer() async throws {
        await withDependencies {
            $0.httpClient = .failing(with: URLError(.notConnectedToInternet))
        } operation: {
            await #expect(throws: SponsorFetchError.couldNotReachServer) {
                try await SponsorsRepository.liveValue.fetch()
            }
        }
    }

    @Test func whenBodyIsUnreadable_shouldThrowInvalidResponse() async throws {
        await withDependencies {
            $0.httpClient = .responding(with: Data("nonsense".utf8), statusCode: 200)
        } operation: {
            await #expect(throws: SponsorFetchError.invalidResponse) {
                try await SponsorsRepository.liveValue.fetch()
            }
        }
    }

    @Test func whenMapperRefuses_shouldThrowInvalidResponse() async throws {
        let data = SponsorsJSON.list(SponsorsJSON.sponsor(level: "bronze"))

        await withDependencies {
            $0.httpClient = .responding(with: data, statusCode: 200)
        } operation: {
            await #expect(throws: SponsorFetchError.invalidResponse) {
                try await SponsorsRepository.liveValue.fetch()
            }
        }
    }

    @Test(arguments: [404, 500])
    func whenServerRefuses_shouldThrowUnknown(statusCode: Int) async throws {
        let data = SponsorsJSON.list(SponsorsJSON.sponsor())

        await withDependencies {
            $0.httpClient = .responding(with: data, statusCode: statusCode)
        } operation: {
            await #expect(throws: SponsorFetchError.unknown) {
                try await SponsorsRepository.liveValue.fetch()
            }
        }
    }

    @Test func whenDecoded_shouldReturnWhateverTheMapperMakes() async throws {
        let data = SponsorsJSON.list(SponsorsJSON.sponsor(id: "ignored"))

        let sponsors = try await withDependencies {
            $0.httpClient = .responding(with: data, statusCode: 200)
            $0.sponsorMapper = SponsorMapper { _ in
                Sponsors([.fixture(id: SponsorID("from-the-mapper"))])
            }
        } operation: {
            try await SponsorsRepository.liveValue.fetch()
        }

        #expect(sponsors.sponsors(at: .platinum).map(\.id) == [SponsorID("from-the-mapper")])
    }
}
