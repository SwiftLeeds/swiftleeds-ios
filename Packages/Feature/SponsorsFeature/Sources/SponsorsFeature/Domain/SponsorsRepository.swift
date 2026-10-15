import Dependencies

/// Reads the sponsors.
package struct SponsorsRepository: Sendable {
    package var fetch: @Sendable () async throws(SponsorFetchError) -> Sponsors

    package init(fetch: @escaping @Sendable () async throws(SponsorFetchError) -> Sponsors) {
        self.fetch = fetch
    }
}

extension SponsorsRepository: TestDependencyKey {
    package static let testValue = SponsorsRepository(
        fetch: { () async throws(SponsorFetchError) -> Sponsors in
            reportIssue("SponsorsRepository.fetch is unimplemented")
            throw .unknown
        }
    )
}

extension DependencyValues {
    package var sponsorsRepository: SponsorsRepository {
        get { self[SponsorsRepository.self] }
        set { self[SponsorsRepository.self] = newValue }
    }
}
