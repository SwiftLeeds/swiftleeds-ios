import LogKit

/// How the outcome of a sponsors fetch reads in a log.
struct LoggedSponsorsFetchOutcome {
    let level: LogLevel
    let message: LogMessage

    // Carries no field. The mapper already recorded the count.
    static let success = LoggedSponsorsFetchOutcome(
        level: .info,
        message: "The sponsors loaded"
    )
}
