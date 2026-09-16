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

        // An offline request fails within a frame, so without a floor a retry shows no spinner.
        private static let retrySpinnerMinimum = Duration.milliseconds(500)

        func load() async {
            await showCurrentSchedule(keepingSpinnerForAtLeast: .zero)
        }

        func select(_ event: Schedule.Event) async {
            currentEvent = event
            state = .loading

            await showSchedule(for: event, keepingSpinnerForAtLeast: .zero)
        }

        func retry() async {
            state = .loading

            if let currentEvent {
                await showSchedule(for: currentEvent, keepingSpinnerForAtLeast: Self.retrySpinnerMinimum)
            } else {
                await showCurrentSchedule(keepingSpinnerForAtLeast: Self.retrySpinnerMinimum)
            }
        }

        private func showCurrentSchedule(keepingSpinnerForAtLeast minimum: Duration) async {
            @Dependency(\.fetchCurrentSchedule) var fetchCurrentSchedule
            let spinnerMinimum = startTimer(lasting: minimum)

            do throws(ScheduleFetchError) {
                show(try await fetchCurrentSchedule())
            } catch {
                await spinnerMinimum.value
                // Leaving the screen cancels this load, and the next appearance starts another.
                guard Task.isCancelled == false else { return }
                state = .failed(conference: currentEvent?.name, reason: error)
            }
        }

        private func showSchedule(
            for event: Schedule.Event,
            keepingSpinnerForAtLeast minimum: Duration
        ) async {
            @Dependency(\.fetchSchedule) var fetchSchedule
            let spinnerMinimum = startTimer(lasting: minimum)

            do throws(ScheduleFetchError) {
                let schedule = try await fetchSchedule(for: event.id)
                guard isStillSelected(event) else { return }
                show(schedule)
            } catch {
                await spinnerMinimum.value
                guard isStillSelected(event) else { return }
                state = .failed(conference: event.name, reason: error)
            }
        }

        private func startTimer(lasting duration: Duration) -> Task<Void, Never> {
            @Dependency(\.continuousClock) var clock
            return Task { try? await clock.sleep(for: duration) }
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
