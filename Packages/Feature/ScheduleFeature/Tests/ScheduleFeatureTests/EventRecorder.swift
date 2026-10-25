import Foundation

/// A record of each event a `ScheduleRepository` is asked for.
actor EventRecorder {
    /// The events asked for, in order, with `nil` standing for the current schedule.
    private(set) var events: [UUID?] = []

    /// Records an event the repository was asked for.
    ///
    /// - Parameter event: The event asked for, or `nil` for the current schedule.
    func record(_ event: UUID?) {
        events.append(event)
    }
}
