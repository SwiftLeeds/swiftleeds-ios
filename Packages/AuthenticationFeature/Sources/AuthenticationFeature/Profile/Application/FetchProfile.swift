import Dependencies

package struct FetchProfile: Sendable {
    private var perform: @Sendable () async throws(AttendeeFetchError) -> Attendee

    private init(perform: @escaping @Sendable () async throws(AttendeeFetchError) -> Attendee) {
        self.perform = perform
    }

    package func callAsFunction() async throws(AttendeeFetchError) -> Attendee {
        try await perform()
    }
}

extension FetchProfile {
    package static var live: FetchProfile {
        FetchProfile { () async throws(AttendeeFetchError) -> Attendee in
            @Dependency(\.attendeeRepository) var attendeeRepository
            return try await attendeeRepository.fetch()
        }
    }
}
