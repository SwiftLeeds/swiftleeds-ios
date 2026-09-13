#if canImport(UIKit)
import Combine
import Dependencies
import ScheduleFeature

@MainActor
final class ScheduleViewModel: ObservableObject {
    @Published private(set) var state = ScheduleContentView.ScreenState.loading
    @Published private(set) var events: [Schedule.Event] = []
    @Published private(set) var currentEvent: Schedule.Event?

    func load() async {
        @Dependency(\.fetchCurrentSchedule) var fetchCurrentSchedule

        do {
            show(try await fetchCurrentSchedule())
        } catch {
            state = .failed(conference: currentEvent?.name)
        }
    }

    func select(_ event: Schedule.Event) async {
        @Dependency(\.fetchSchedule) var fetchSchedule

        currentEvent = event
        state = .loading

        do {
            show(try await fetchSchedule(for: event.id))
        } catch {
            state = .failed(conference: event.name)
        }
    }

    private func show(_ schedule: Schedule) {
        events = schedule.data.events.sorted { $0.name < $1.name }

        // Set the event to the current one on first launch
        if currentEvent == nil {
            currentEvent = schedule.data.event
        }

        let days = schedule.data.days
            .sorted { $0.date < $1.date }
            .map { day in
                Schedule.Day(
                    date: day.date,
                    name: day.name,
                    slots: day.slots.sorted { $0.startTime < $1.startTime }
                )
            }

        guard days.isEmpty == false else {
            state = .failed(conference: schedule.data.event.name)
            return
        }

        state = .loaded(days: days, showSlido: showsSlido(for: schedule.data.event))
    }

    // Only show slido links on the day of the event
    private func showsSlido(for event: Schedule.Event) -> Bool {
        let days = event.daysUntil
        return days <= 0 && days >= -1
    }
}
#endif
