import LogKit

/// How the outcome of one HTTP request reads in a log.
struct LoggedRequestOutcome {
    let level: LogLevel
    let message: LogMessage

    /// A response runs on every request in the app, so it records at the level the platform drops
    /// unless someone is watching. The status is data, not severity: whoever reads the response
    /// decides whether a 500 is a failure.
    static func success(request: String, statusCode: Int) -> LoggedRequestOutcome {
        LoggedRequestOutcome(
            level: .debug,
            message: """
            A response arrived: \
            \(request, name: "request", privacy: .open), \
            \(statusCode, name: "statusCode", privacy: .open)
            """
        )
    }

    static func failure(request: String, error: any Error) -> LoggedRequestOutcome {
        LoggedRequestOutcome(
            level: .error,
            message: """
            A request could not reach the server: \
            \(request, name: "request", privacy: .open), \
            \(error, name: "reason", privacy: .open)
            """
        )
    }
}
