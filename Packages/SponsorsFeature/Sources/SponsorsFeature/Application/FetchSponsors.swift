import Dependencies

public struct FetchSponsors: Sendable {
    private var perform: @Sendable () async throws(SponsorFetchError) -> Sponsors

    public init(perform: @escaping @Sendable () async throws(SponsorFetchError) -> Sponsors) {
        self.perform = perform
    }

    public func callAsFunction() async throws(SponsorFetchError) -> Sponsors {
        try await perform()
    }
}

extension FetchSponsors: DependencyKey {
    public static var liveValue: FetchSponsors {
        FetchSponsors { () async throws(SponsorFetchError) -> Sponsors in
            @Dependency(\.sponsorsRepository) var sponsorsRepository
            return try await sponsorsRepository.fetch()
        }
    }

    public static let testValue = FetchSponsors(
        perform: { () async throws(SponsorFetchError) -> Sponsors in
            reportIssue("FetchSponsors is unimplemented")
            throw .unknown
        }
    )
}

extension DependencyValues {
    public var fetchSponsors: FetchSponsors {
        get { self[FetchSponsors.self] }
        set { self[FetchSponsors.self] = newValue }
    }
}
