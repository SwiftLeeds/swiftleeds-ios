import Dependencies
import Foundation
import NetworkKit
import SponsorsFeature
import Testing

/// Drives the composed `liveValue` with only the transport stubbed, so it also
/// pins that the query reaches the mapper at all.
@Suite struct SponsorsQueryIntegrationTests {
    @Test func whenServerAnswersWell_shouldReturnSponsors() async throws {
        let data = SponsorsJSON.list(SponsorsJSON.sponsor(id: "a", level: "gold"))

        let sponsors = try await withDependencies {
            $0.httpClient = .responding(with: data, statusCode: 200)
        } operation: {
            try await SponsorsQuery.liveValue.load()
        }

        #expect(sponsors.map(\.id) == ["a"])
        #expect(sponsors.first?.level == .gold)
    }

    @Test func whenRequestFails_shouldThrowCouldNotReachServer() async throws {
        await withDependencies {
            $0.httpClient = .failing(with: URLError(.notConnectedToInternet))
        } operation: {
            await #expect(throws: SponsorFetchError.couldNotReachServer) {
                try await SponsorsQuery.liveValue.load()
            }
        }
    }

    @Test func whenBodyIsUnreadable_shouldThrowInvalidResponse() async throws {
        await withDependencies {
            $0.httpClient = .responding(with: Data("nonsense".utf8), statusCode: 200)
        } operation: {
            await #expect(throws: SponsorFetchError.invalidResponse) {
                try await SponsorsQuery.liveValue.load()
            }
        }
    }

    @Test func whenLevelIsUnknown_shouldThrowInvalidResponse() async throws {
        let data = SponsorsJSON.list(SponsorsJSON.sponsor(level: "bronze"))

        await withDependencies {
            $0.httpClient = .responding(with: data, statusCode: 200)
        } operation: {
            await #expect(throws: SponsorFetchError.invalidResponse) {
                try await SponsorsQuery.liveValue.load()
            }
        }
    }

    @Test func whenServerRefuses_shouldThrowUnknown() async throws {
        let data = SponsorsJSON.list(SponsorsJSON.sponsor())

        await withDependencies {
            $0.httpClient = .responding(with: data, statusCode: 500)
        } operation: {
            await #expect(throws: SponsorFetchError.unknown) {
                try await SponsorsQuery.liveValue.load()
            }
        }
    }
}
