import Dependencies
import Foundation
import LogKit

extension AttendeeMapper {
    /// Records why a response was rejected, then rethrows it unchanged.
    ///
    /// Wraps the mapper rather than the repository because the repository has already narrowed the
    /// failure to `AttendeeFetchError`, which carries no reason.
    func loggingFailures() -> AttendeeMapper {
        AttendeeMapper { data, response throws(AttendeeResponseFailure) in
            do throws(AttendeeResponseFailure) {
                return try map(data, response)
            } catch {
                // Resolved per call, so a test overriding \.log is honoured. Resolving it while
                // building liveValue would capture whichever log existed first.
                @Dependency(\.log) var log
                log(.error, "profile", "The attendee response was rejected", fields: [
                    .open("reason", .string("\(error)"))
                ])
                throw error
            }
        }
    }
}
