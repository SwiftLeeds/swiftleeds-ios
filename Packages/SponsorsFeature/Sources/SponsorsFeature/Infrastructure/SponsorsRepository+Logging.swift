import Dependencies
import LogKit

extension SponsorsRepository {
    /// Records the outcome the user got, then returns or rethrows.
    ///
    /// The line names the outcome, not the cause. A transport or mapping cause reaches the log at
    /// its own seam. A body that fails to decode has no seam and reaches the log as a rejection only.
    package func logging() -> SponsorsRepository {
        SponsorsRepository { () async throws(SponsorFetchError) -> Sponsors in
            // Resolved per call, so a test overriding \.log is honored. Resolving it while
            // building liveValue would capture whichever log existed first.
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
