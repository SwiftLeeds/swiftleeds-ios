import LogKit

/// How a sign-in failure reads in a log.
struct LoggedSignInError {
    let level: LogLevel
    let message: LogMessage

    init?(_ error: LoginRequestError) {
        switch error {
        case let .couldNotEncodeRequest(cause):
            level = .error
            message = "The sign-in request could not be encoded: \(cause, name: "reason", privacy: .open)"
        case .transportFailed:
            // Already logged once, at the transport seam.
            return nil
        }
    }

}
