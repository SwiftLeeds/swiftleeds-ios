import Foundation
import ScheduleDomain

extension Schedule.Event {
    /// Returns an event for a test, with a fixed venue and date.
    ///
    /// ```swift
    /// let event = Schedule.Event.fixture(named: "SwiftLeeds 2025")
    /// ```
    ///
    /// - Parameters:
    ///   - name: The event's name. Defaults to "SwiftLeeds 2026".
    ///   - id: The event's identity. Defaults to a new random value.
    /// - Returns: An event with the given name and identity.
    public static func fixture(
        named name: String = "SwiftLeeds 2026",
        id: UUID = UUID(),
    ) -> Self {
        Self(
            id: id,
            name: name,
            location: "The Playhouse, Leeds",
            date: Date(timeIntervalSince1970: 0),
        )
    }
}
