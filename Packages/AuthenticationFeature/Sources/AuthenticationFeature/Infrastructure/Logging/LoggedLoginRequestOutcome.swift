import LogKit

// There is no success case. The gateway returns what the mapper handed back, and the mapper
// already recorded that, so a success here would only repeat it.
struct LoggedLoginRequestOutcome {
    let level: LogLevel
    let message: LogMessage

    // Returns `nil` for a transport failure, which the decorator on `HTTPClient` already recorded.
    static func failure(_ error: LoginRequestError) -> LoggedLoginRequestOutcome? {
        switch error {
        case let .couldNotEncodeRequest(cause):
            LoggedLoginRequestOutcome(
                level: .error,
                message: "The sign-in request could not be encoded: \(cause, name: "reason", privacy: .open)"
            )
        case .transportFailed:
            nil
        }
    }
}
