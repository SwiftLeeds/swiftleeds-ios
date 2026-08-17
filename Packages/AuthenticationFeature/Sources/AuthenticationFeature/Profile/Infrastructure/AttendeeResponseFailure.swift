import LogKit

/// Internal on purpose: `AttendeeFetchError` is what callers see, and it carries no diagnostic
/// payload. This is what middleware between the two gets to read.
enum AttendeeResponseFailure: Error {
    case couldNotRead(any Error)
    case unauthorized
    case unexpectedStatus(Int)
}

extension AttendeeResponseFailure: LogDescribable {
    var logDescription: String {
        switch self {
        case let .couldNotRead(cause):
            "couldNotRead(\(String(logDescribing: cause)))"
        case .unauthorized:
            "unauthorized"
        case let .unexpectedStatus(code):
            "unexpectedStatus(\(code))"
        }
    }
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
