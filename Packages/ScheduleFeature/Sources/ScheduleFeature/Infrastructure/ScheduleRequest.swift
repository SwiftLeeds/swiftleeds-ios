import Foundation

package enum ScheduleRequest: Equatable, Hashable, Sendable {
    case current
    case event(UUID)
}
