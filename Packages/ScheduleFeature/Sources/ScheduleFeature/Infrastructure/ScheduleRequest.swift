import Foundation

/// Which conference's schedule a caller wants.
///
/// The app cannot name the current conference until the backend answers, so asking for it
/// is a different request rather than a missing argument.
package enum ScheduleRequest: Equatable, Hashable, Sendable {
    case current
    case event(UUID)
}
