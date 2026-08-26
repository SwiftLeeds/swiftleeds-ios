import Dependencies
import LogKit

extension FetchProfile {
    /// Records the outcome the user got, then rethrows.
    ///
    /// A failure's cause already reached the log at the seam that knew it: the transport or the
    /// mapper. This line says what that meant for the person waiting for their profile.
    public func logging() -> FetchProfile {
        FetchProfile { () async throws(AttendeeFetchError) -> Profile in
            // Resolved per call, so a test overriding \.log is honoured. Resolving it while
            // building liveValue would capture whichever log existed first.
            @Dependency(\.log) var log
            do throws(AttendeeFetchError) {
                let profile = try await self()
                let entry = LoggedProfileFetchOutcome.success
                log(entry.level, .profile, entry.message)
                return profile
            } catch {
                let entry = LoggedProfileFetchOutcome.failure(error)
                log(entry.level, .profile, entry.message)
                throw error
            }
        }
    }
}
