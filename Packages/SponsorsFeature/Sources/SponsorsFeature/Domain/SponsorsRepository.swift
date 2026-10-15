import Dependencies

/// The source of the sponsors.
package struct SponsorsRepository: Sendable {
    /// Fetches every sponsor, grouped by level.
    /// - Throws: A ``SponsorFetchError`` when the server cannot be reached, or
    ///   its response is refused or unexpected.
    package var fetch: @Sendable () async throws(SponsorFetchError) -> Sponsors

    /// Creates a repository.
    package init(fetch: @escaping @Sendable () async throws(SponsorFetchError) -> Sponsors) {
        self.fetch = fetch
    }
}

extension SponsorsRepository: TestDependencyKey {
    /// A stub that reports an issue, then throws ``SponsorFetchError/unknown``.
    package static let testValue = SponsorsRepository(
        fetch: { () async throws(SponsorFetchError) -> Sponsors in
            reportIssue("SponsorsRepository.fetch is unimplemented")
            throw .unknown
        }
    )
}

extension DependencyValues {
    /// The sponsors repository the current context uses.
    package var sponsorsRepository: SponsorsRepository {
        get { self[SponsorsRepository.self] }
        set { self[SponsorsRepository.self] = newValue }
    }
}
