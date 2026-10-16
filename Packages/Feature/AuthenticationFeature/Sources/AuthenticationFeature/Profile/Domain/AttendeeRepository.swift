import Dependencies

/// The source of the attendee for the current session.
package struct AttendeeRepository: Sendable {
    /// Fetches the attendee for the current session.
    /// - Throws: An ``AttendeeFetchError`` when the session is refused, the
    ///   server cannot be reached, its answer cannot be read, or the status is
    ///   unexpected.
    package var fetch: @Sendable () async throws(AttendeeFetchError) -> Attendee

    /// Creates a repository.
    package init(fetch: @escaping @Sendable () async throws(AttendeeFetchError) -> Attendee) {
        self.fetch = fetch
    }
}

extension AttendeeRepository: TestDependencyKey {
    /// A stub that reports an issue, then throws ``AttendeeFetchError/unknown``.
    package static let testValue = AttendeeRepository(
        fetch: { () async throws(AttendeeFetchError) -> Attendee in
            reportIssue("AttendeeRepository.fetch is unimplemented")
            throw .unknown
        }
    )
}

extension DependencyValues {
    /// The attendee repository the current context uses.
    package var attendeeRepository: AttendeeRepository {
        get { self[AttendeeRepository.self] }
        set { self[AttendeeRepository.self] = newValue }
    }
}
