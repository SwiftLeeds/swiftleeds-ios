import LogKit

/// How the outcome of a profile fetch reads in a log.
struct LoggedProfileFetchOutcome {
    let level: LogLevel
    let message: LogMessage

    init(_ error: AttendeeFetchError) {
        switch error {
        case .unauthorized:
            // Expected: the session expired or was revoked. Not a fault in the app.
            level = .notice
            message = "Loading the profile did not finish: the session was not accepted"
        case .invalidResponse:
            level = .error
            message = "Loading the profile did not finish: the server's answer was rejected"
        case .unknown:
            level = .error
            message = "Loading the profile did not finish: the reason is not known"
        }
    }
}
