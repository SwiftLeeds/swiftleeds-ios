import Combine
import Dependencies
import ScheduleFeature

@MainActor
final class ScheduleViewModel: ObservableObject {
    @Published private(set) var hasLoaded = false
    @Published private(set) var event: Schedule.Event?
    @Published private(set) var events: [Schedule.Event] = []
    @Published private(set) var days: [Schedule.Day] = []
    @Published private(set) var currentEvent: Schedule.Event?

    func loadSchedule() async throws {
        @Dependency(\.fetchCurrentSchedule) var fetchCurrentSchedule

        let schedule = try await fetchCurrentSchedule()
        updateSchedule(schedule)
    }

    private func updateSchedule(_ schedule: Schedule) {
        event = schedule.data.event
        events = schedule.data.events.sorted(by: { $0.name < $1.name })

        // Set the event to the current one on first launch
        if currentEvent == nil {
            currentEvent = event
        }

        days = schedule.data.days
            .sorted(by: { $0.date < $1.date })
            .map { day in
                Schedule.Day(
                    date: day.date,
                    name: day.name,
                    slots: day.slots.sorted { $0.startTime < $1.startTime }
                )
            }

        hasLoaded = true
    }

    private func reloadSchedule() async throws {
        @Dependency(\.fetchSchedule) var fetchSchedule

        guard let currentEvent else { return }

        let schedule = try await fetchSchedule(for: currentEvent.id)
        updateSchedule(schedule)
    }

    // Only show slido links on the day of the event
    var showSlido: Bool {
        guard let days = event?.daysUntil else { return false }
        return days <= 0 && days >= -1
    }

    func updateCurrentEvent(_ event: Schedule.Event) {
        currentEvent = event

        Task {
            try? await reloadSchedule()
        }
    }
}
