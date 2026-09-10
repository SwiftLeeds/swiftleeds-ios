import Combine
import Dependencies
import Foundation
import NetworkKit
import SwiftUI

class MyConferenceViewModel: ObservableObject {
    @Published private(set) var hasLoaded = false
    @Published private(set) var event: Schedule.Event?
    @Published private(set) var events: [Schedule.Event] = []
    @Published private(set) var days: [Schedule.Day] = []
    @Published private(set) var currentEvent: Schedule.Event?

    private static let scheduleKey = "Schedule"

    func loadSchedule() async throws {
        do {
            let schedule = try await fetchSchedule(for: nil)
            await updateSchedule(schedule)
            store(schedule)
        } catch {
            guard let stored = storedSchedule() else { throw error }
            await updateSchedule(stored)
        }
    }

    private func fetchSchedule(for event: UUID?) async throws -> Schedule {
        @Dependency(\.httpClient) var httpClient
        @Dependency(\.scheduleMapper) var scheduleMapper

        let (data, response) = try await httpClient.send(Endpoint.schedule(event: event).urlRequest())
        return try scheduleMapper.map(data, response)
    }

    private func store(_ schedule: Schedule) {
        guard let data = try? PropertyListEncoder().encode(schedule) else { return }

        UserDefaults.standard.set(data, forKey: Self.scheduleKey)
        UserDefaults(suiteName: ConferenceConfig.appGroupIdentifier)?.set(data, forKey: Self.scheduleKey)
    }

    private func storedSchedule() -> Schedule? {
        UserDefaults.standard.data(forKey: Self.scheduleKey)
            .flatMap { try? PropertyListDecoder().decode(Schedule.self, from: $0) }
    }

    @MainActor
    private func updateSchedule(_ schedule: Schedule) async {
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
        guard let currentEvent else { return }

        let schedule = try await fetchSchedule(for: currentEvent.id)
        await updateSchedule(schedule)
    }

    var numberOfDaysToConference: Int? {
        guard let days = event?.daysUntil else { return nil }

        // Stop showing ticket sales a week before the event
        if days > 7 {
            return days
        } else {
            return nil
        }
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
