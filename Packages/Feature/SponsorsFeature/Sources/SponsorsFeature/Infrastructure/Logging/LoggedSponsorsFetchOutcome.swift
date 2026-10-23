import LogKit

struct LoggedSponsorsFetchOutcome {
    let level: LogLevel
    let message: LogMessage

    static let success = Self(
        level: .info,
        message: "The sponsors loaded",
    )

    static func failure(_ error: SponsorFetchError) -> Self {
        switch error {
        case .couldNotReachServer:
            Self(
                level: .notice,
                message: "Loading the sponsors did not finish: the server could not be reached",
            )

        case .invalidResponse:
            Self(
                level: .error,
                message: "Loading the sponsors did not finish: the server's answer was rejected",
            )

        case .unknown:
            Self(
                level: .error,
                message: "Loading the sponsors did not finish: the reason is not known",
            )
        }
    }
}
