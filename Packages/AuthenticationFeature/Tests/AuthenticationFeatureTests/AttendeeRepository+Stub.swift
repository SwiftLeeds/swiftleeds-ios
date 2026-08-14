import AuthenticationFeature

extension AttendeeRepository {
    static func returning(_ attendee: Attendee) -> AttendeeRepository {
        AttendeeRepository { attendee }
    }

    static func failing(with error: AttendeeFetchError) -> AttendeeRepository {
        AttendeeRepository { () async throws(AttendeeFetchError) -> Attendee in throw error }
    }
}
