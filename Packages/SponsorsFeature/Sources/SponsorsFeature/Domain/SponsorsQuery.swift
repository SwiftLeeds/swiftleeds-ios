import Dependencies

/// Reads the sponsor list.
package struct SponsorsQuery: Sendable {
    package var load: @Sendable () async throws(SponsorFetchError) -> [Sponsor]

    package init(load: @escaping @Sendable () async throws(SponsorFetchError) -> [Sponsor]) {
        self.load = load
    }
}

extension SponsorsQuery: TestDependencyKey {
    package static let testValue = SponsorsQuery(
        load: { () async throws(SponsorFetchError) -> [Sponsor] in
            reportIssue("SponsorsQuery.load is unimplemented")
            throw .unknown
        }
    )
}

extension DependencyValues {
    package var sponsorsQuery: SponsorsQuery {
        get { self[SponsorsQuery.self] }
        set { self[SponsorsQuery.self] = newValue }
    }
}
