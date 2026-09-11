import Dependencies
import LogKit

extension SponsorMapper {
    /// Records whether the list mapped, then returns or rethrows.
    package func logging() -> SponsorMapper {
        SponsorMapper { list throws(MappingError) in
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
