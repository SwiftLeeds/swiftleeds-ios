import Dependencies
import LogKit

extension SponsorMapper {
    /// Records whether the list mapped, then returns or rethrows.
    ///
    /// The public ``SponsorFetchError`` is deliberately bare, so this is the only place a
    /// rejection's reason survives.
    package func logging() -> SponsorMapper {
        SponsorMapper { list throws(MappingError) in
            // Resolved per call, so a test overriding \.log is honoured. Resolving it while
            // building liveValue would capture whichever log existed first.
            @Dependency(\.log) var log
            do throws(MappingError) {
                return try map(list)
            } catch {
                let entry = LoggedSponsorMappingOutcome.failure(error)
                log(entry.level, .sponsors, entry.message)
                throw error
            }
        }
    }
}
