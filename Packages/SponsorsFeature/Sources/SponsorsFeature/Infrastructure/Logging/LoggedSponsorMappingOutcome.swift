import LogKit

// How the outcome of mapping a sponsor list reads in a log.
struct LoggedSponsorMappingOutcome {
    let level: LogLevel
    let message: LogMessage

    static func success(count: Int) -> LoggedSponsorMappingOutcome {
        LoggedSponsorMappingOutcome(
            level: .debug,
            message: "The sponsor list was mapped: \(count, name: "count", privacy: .open)"
        )
    }

    // Everything is open: a sponsor is advertised, and the value came from a public endpoint.
    static func failure(_ error: SponsorMapper.MappingError) -> LoggedSponsorMappingOutcome {
        LoggedSponsorMappingOutcome(
            level: .error,
            message: """
            The sponsor \(error.sponsor, name: "sponsor", privacy: .open) had an invalid \
            \(error.field.rawValue, name: "field", privacy: .open): \
            \(error.value, name: "value", privacy: .open)
            """
        )
    }
}
