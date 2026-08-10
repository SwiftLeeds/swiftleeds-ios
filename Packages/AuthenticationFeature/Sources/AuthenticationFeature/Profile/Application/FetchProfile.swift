import Dependencies

public struct FetchProfile: Sendable {
    private var perform: @Sendable () async throws(AttendeeFetchError) -> Profile

    private init(perform: @escaping @Sendable () async throws(AttendeeFetchError) -> Profile) {
        self.perform = perform
    }

    public func callAsFunction() async throws -> Profile {
        try await perform()
    }
}

extension FetchProfile: DependencyKey {
    public static var liveValue: FetchProfile {
        FetchProfile { () async throws(AttendeeFetchError) -> Profile in
            @Dependency(\.attendeeRepository) var attendeeRepository
            let attendee = try await attendeeRepository.fetch()
            return Profile(attendee)
        }
    }

    public static let testValue = FetchProfile(
        perform: { () async throws(AttendeeFetchError) -> Profile in
            reportIssue("FetchProfile is unimplemented")
            throw .unknown
        }
    )
}

extension DependencyValues {
    public var fetchProfile: FetchProfile {
        get { self[FetchProfile.self] }
        set { self[FetchProfile.self] = newValue }
    }
}
