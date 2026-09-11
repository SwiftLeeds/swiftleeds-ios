import Dependencies
import LogKit

extension SponsorsRepository {
    /// Records the outcome the user got, then rethrows.
    ///
    /// A failure's cause already reached the log at the seam that knew it: the transport or the
    /// mapper. This line says what that meant for the person waiting for the sponsors.
    package func logging() -> SponsorsRepository {
        SponsorsRepository { () async throws(SponsorFetchError) -> Sponsors in
            // Resolved per call, so a test overriding \.log is honoured. Resolving it while
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
