import Dependencies

package struct AttendeeRepository: Sendable {
    package var fetch: @Sendable () async throws(AttendeeFetchError) -> Attendee

    package init(fetch: @escaping @Sendable () async throws(AttendeeFetchError) -> Attendee) {
        self.fetch = fetch
    }
}

extension AttendeeRepository: TestDependencyKey {
    package static let testValue = AttendeeRepository(
        fetch: { () async throws(AttendeeFetchError) -> Attendee in
            reportIssue("AttendeeRepository.fetch is unimplemented")
            throw .unknown
        }
    )
}

extension DependencyValues {
    package var attendeeRepository: AttendeeRepository {
        get { self[AttendeeRepository.self] }
        set { self[AttendeeRepository.self] = newValue }
    }
}
