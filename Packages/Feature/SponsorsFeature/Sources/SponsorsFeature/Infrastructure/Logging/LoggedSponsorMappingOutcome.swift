import LogKit

struct LoggedSponsorMappingOutcome {
    let level: LogLevel
    let message: LogMessage

    static func success(count: Int) -> Self {
        Self(
            level: .debug,
            message: "The sponsor list was mapped: \(count, name: "count", privacy: .open)",
        )
    }

    static func failure(_ error: SponsorMapper.MappingError) -> Self {
        Self(
            level: .error,
            message: """
                The sponsor \(error.sponsor, name: "sponsor", privacy: .open) had an invalid \
                \(error.field.rawValue, name: "field", privacy: .open): \
                \(error.value, name: "value", privacy: .open)
                """,
        )
    }
}
