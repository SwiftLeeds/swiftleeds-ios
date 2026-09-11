import Dependencies
import SponsorsFeature
import Testing

@Suite struct FetchSponsorsTests {
    @Test func whenQueryReturnsSponsors_shouldGroupThemByLevel() async throws {
        let query = SponsorsQuery.returning([
            .fixture(id: SponsorID("a"), level: .silver),
            .fixture(id: SponsorID("b"), level: .platinum),
        ])

        let sponsors = try await withDependencies {
            $0.sponsorsQuery = query
        } operation: {
            try await FetchSponsors.liveValue()
        }

        #expect(sponsors.rankedLevels == [.platinum, .silver])
        #expect(sponsors.sponsors(at: .platinum).map(\.id) == [SponsorID("b")])
    }

    @Test func whenQueryReturnsNothing_shouldReturnEmpty() async throws {
        let sponsors = try await withDependencies {
            $0.sponsorsQuery = .returning([])
        } operation: {
            try await FetchSponsors.liveValue()
        }

        #expect(sponsors.isEmpty)
    }

    @Test func whenQueryFails_shouldThrowTheSameError() async {
        await withDependencies {
            $0.sponsorsQuery = .failing(with: .couldNotReachServer)
        } operation: {
            await #expect(throws: SponsorFetchError.couldNotReachServer) {
                try await FetchSponsors.liveValue()
            }
        }
    }
}
