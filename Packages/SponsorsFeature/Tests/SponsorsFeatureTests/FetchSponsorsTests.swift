import Dependencies
import SponsorsFeature
import Testing

@Suite struct FetchSponsorsTests {
    @Test func whenRepositoryReturnsSponsors_shouldHandThemBack() async throws {
        let expected = Sponsors([
            .fixture(id: SponsorID("a"), level: .silver),
            .fixture(id: SponsorID("b"), level: .platinum),
        ])

        let sponsors = try await withDependencies {
            $0.sponsorsRepository = .returning(expected)
        } operation: {
            try await FetchSponsors.liveValue()
        }

        #expect(sponsors == expected)
    }

    @Test func whenRepositoryReturnsNothing_shouldReturnEmpty() async throws {
        let sponsors = try await withDependencies {
            $0.sponsorsRepository = .returning(Sponsors([]))
        } operation: {
            try await FetchSponsors.liveValue()
        }

        #expect(sponsors.isEmpty)
    }

    @Test func whenRepositoryFails_shouldThrowTheSameError() async {
        await withDependencies {
            $0.sponsorsRepository = .failing(with: .couldNotReachServer)
        } operation: {
            await #expect(throws: SponsorFetchError.couldNotReachServer) {
                try await FetchSponsors.liveValue()
            }
        }
    }
}
