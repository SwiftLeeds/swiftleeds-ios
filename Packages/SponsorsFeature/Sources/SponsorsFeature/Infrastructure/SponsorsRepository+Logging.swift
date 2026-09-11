import Dependencies
import LogKit

extension SponsorsRepository {
    /// Records the outcome the user got, then returns or rethrows.
    package func logging() -> SponsorsRepository {
        SponsorsRepository { () async throws(SponsorFetchError) -> Sponsors in
            @Dependency(\.log) var log
            do throws(SponsorFetchError) {
                let sponsors = try await fetch()
                let entry = LoggedSponsorsFetchOutcome.success
                log(entry.level, .sponsors, entry.message)
                return sponsors
            } catch {
                let entry = LoggedSponsorsFetchOutcome.failure(error)
                log(entry.level, .sponsors, entry.message)
                throw error
            }
        }
    }
}
