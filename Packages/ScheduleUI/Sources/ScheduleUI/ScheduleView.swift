#if canImport(UIKit)
import Dependencies
import ScheduleFeature
import SwiftUI

/// The schedule screen. It fetches the schedule when it appears.
public struct ScheduleView: View {
    @State private var viewModel = ViewModel()

    public init() {}

    public var body: some View {
        ScheduleContentView(
            state: viewModel.state,
            events: viewModel.events,
            currentEvent: viewModel.currentEvent,
            selectEvent: { event in
                Task { await viewModel.select(event) }
            },
            retry: {
                Task { await viewModel.retry() }
            }
        )
        .task {
            await viewModel.load()
        }
    }
}

extension ScheduleView {
    @Observable
    @MainActor
    fileprivate final class ViewModel {
        private(set) var state = ScheduleContentView.ScreenState.loading
        private(set) var events: [Schedule.Event] = []
        private(set) var currentEvent: Schedule.Event?

        func load() async {
            @Dependency(\.fetchCurrentSchedule) var fetchCurrentSchedule

            do throws(ScheduleFetchError) {
                show(try await fetchCurrentSchedule())
            } catch {
                // Leaving the screen cancels this load, and the next appearance starts another.
                guard Task.isCancelled == false else { return }
                state = .failed(conference: currentEvent?.name, reason: error)
            }
        }

        func select(_ event: Schedule.Event) async {
            @Dependency(\.fetchSchedule) var fetchSchedule

            currentEvent = event
            state = .loading

            do throws(ScheduleFetchError) {
                let schedule = try await fetchSchedule(for: event.id)
                guard isStillSelected(event) else { return }
                show(schedule)
            } catch {
                guard isStillSelected(event) else { return }
                state = .failed(conference: event.name, reason: error)
            }
        }

        func retry() async {
            state = .loading

            if let currentEvent {
                await select(currentEvent)
            } else {
                await load()
            }
        }

        private func isStillSelected(_ event: Schedule.Event) -> Bool {
            currentEvent?.id == event.id
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

            state = .loaded(days: days, showSlido: showsSlido(for: schedule.data.event))
        }

        // Only show slido links on the day of the event
        private func showsSlido(for event: Schedule.Event) -> Bool {
            let days = event.daysUntil
            return days <= 0 && days >= -1
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
    }
}
#endif
