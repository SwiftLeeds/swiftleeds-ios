import Foundation

/// A schedule kept on the device, and when it was kept.
package struct StoredSchedule: Codable, Sendable {
    /// How long a stored schedule is worth serving. The backend sends no cache headers,
    /// so the app picks the number.
    private static let lifetime: TimeInterval = 60 * 60 * 24

    package let schedule: Schedule
    package let storedAt: Date

    package init(schedule: Schedule, storedAt: Date) {
        self.schedule = schedule
        self.storedAt = storedAt
    }

    package func isFresh(at now: Date) -> Bool {
        now.timeIntervalSince(storedAt) < Self.lifetime
    }
}
