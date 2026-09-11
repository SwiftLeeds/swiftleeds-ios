import LogKit

// How the outcome of a sponsors fetch reads in a log.
struct LoggedSponsorsFetchOutcome {
    let level: LogLevel
    let message: LogMessage

    static let success = LoggedSponsorsFetchOutcome(
        level: .info,
        message: "The sponsors loaded"
    )

    static func failure(_ error: SponsorFetchError) -> LoggedSponsorsFetchOutcome {
        switch error {
        case .couldNotReachServer:
            // Expected: the device is offline. The user can retry.
            LoggedSponsorsFetchOutcome(
                level: .notice,
                message: "Loading the sponsors did not finish: the server could not be reached"
            )
        case .invalidResponse:
            LoggedSponsorsFetchOutcome(
                level: .error,
                message: "Loading the sponsors did not finish: the server's answer was rejected"
            )
        case .unknown:
            LoggedSponsorsFetchOutcome(
                level: .error,
                message: "Loading the sponsors did not finish: the reason is not known"
            )
        }
    }
}
