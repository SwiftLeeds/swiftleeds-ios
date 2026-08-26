import Dependencies
import LogKit

extension FetchProfile {
    /// Records the outcome the user got, then rethrows.
    ///
    /// The cause already reached the log at the seam that knew it: the transport or the mapper.
    /// This line says what that cost the person waiting for their profile.
    public func loggingFailedOutcomes() -> FetchProfile {
        FetchProfile { () async throws(AttendeeFetchError) -> Profile in
            do throws(AttendeeFetchError) {
                return try await self()
            } catch {
                // Resolved per call, so a test overriding \.log is honoured. Resolving it while
                // building liveValue would capture whichever log existed first.
                @Dependency(\.log) var log
                let entry = LoggedAttendeeFetchOutcome(error)
                log(entry.level, .profile, entry.message)
                throw error
            }
        }
    }
}
