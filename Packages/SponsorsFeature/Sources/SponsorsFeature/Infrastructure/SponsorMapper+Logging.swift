import Dependencies
import LogKit

extension SponsorMapper {
    /// Records whether the list mapped, then returns or rethrows.
    ///
    /// The only place a rejection's reason survives. The public ``SponsorFetchError`` does not
    /// carry it.
    package func logging() -> SponsorMapper {
        SponsorMapper { list throws(MappingError) in
            // Resolved per call, so a test overriding \.log is honored. Resolving it while
            // building liveValue would capture whichever log existed first.
            @Dependency(\.log) var log
            do throws(MappingError) {
                let sponsors = try map(list)
                let entry = LoggedSponsorMappingOutcome.success(count: list.data.count)
                log(entry.level, .sponsors, entry.message)
                return sponsors
            } catch {
                let entry = LoggedSponsorMappingOutcome.failure(error)
                log(entry.level, .sponsors, entry.message)
                throw error
            }
        }
    }
}
