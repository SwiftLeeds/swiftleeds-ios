import LogKit

extension AttendeeMapper {
    /// Internal on purpose: `AttendeeFetchError` is what callers see, and it carries no diagnostic
    /// payload. This is what middleware between the two gets to read.
    enum ResponseError: Error {
        case couldNotRead(any Error)
        case unauthorized
        case unexpectedStatus(Int)
    }
}

extension AttendeeMapper.ResponseError: LogDescribable {
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
    init(_ error: AttendeeMapper.ResponseError) {
        switch error {
        case .couldNotRead:
            self = .invalidResponse
        case .unauthorized:
            self = .unauthorized
        case .unexpectedStatus:
            self = .unknown
        }
    }
}
