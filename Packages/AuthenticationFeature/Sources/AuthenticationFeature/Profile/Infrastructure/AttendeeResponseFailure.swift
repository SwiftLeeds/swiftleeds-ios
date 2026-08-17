/// Why a response could not become an `Attendee`, with enough detail to diagnose it.
///
/// Internal on purpose: `AttendeeFetchError` is what callers see, and it carries no diagnostic
/// payload. This is what middleware between the two gets to read.
enum AttendeeResponseFailure: Error {
    case couldNotRead(any Error)
    case unauthorized
    case unexpectedStatus(Int)
}

extension AttendeeFetchError {
    init(_ failure: AttendeeResponseFailure) {
        switch failure {
        case .couldNotRead:
            self = .invalidResponse
        case .unauthorized:
            self = .unauthorized
        case .unexpectedStatus:
            self = .unknown
        }
    }
}
