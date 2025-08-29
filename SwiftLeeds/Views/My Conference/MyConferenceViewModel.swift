//
//  MyConferenceViewModel.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 01/08/2022.
//

import Foundation
import Combine
import SwiftUI

class MyConferenceViewModel: ObservableObject {
    @Published private(set) var hasLoaded = false
    @Published private(set) var event: Schedule.Event?
    @Published private(set) var events: [Schedule.Event] = []
    @Published private(set) var days: [Schedule.Day] = []
    @Published private(set) var currentEvent: Schedule.Event?

    func loadSchedule() async throws {
        do {
            let schedule = try await URLSession.awaitConnectivity.decode(
                Requests.schedule,
                dateDecodingStrategy: Requests.scheduleDateDecodingStrategy
            )
            await updateSchedule(schedule)

            do {
                let data = try PropertyListEncoder().encode(schedule)
                UserDefaults(suiteName: "group.uk.co.swiftleeds")?.setValue(data, forKey: "Schedule")
            } catch {
                throw(error)
            }
        } catch {
            if let cachedResponse = try? await URLSession.shared.cached(
                Requests.schedule,
                dateDecodingStrategy: Requests.scheduleDateDecodingStrategy
            ) {
                await updateSchedule(cachedResponse)
            } else {
                throw(error)
            }
        }
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

        let schedule = try await URLSession.awaitConnectivity.decode(
            Requests.schedule(for: currentEvent.id),
            dateDecodingStrategy: Requests.scheduleDateDecodingStrategy,
            filename: "schedule-\(currentEvent.id.uuidString)"
        )
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

    static let stringDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }()

    func updateCurrentEvent(_ event: Schedule.Event) {
        currentEvent = event

        Task {
            try? await reloadSchedule()
        }
    }
}
