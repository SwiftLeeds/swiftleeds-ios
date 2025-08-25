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
    @Published private(set) var days: [String] = []
    @Published private(set) var slots: [String: [Schedule.Slot]] = [:]
    @Published private(set) var currentEvent: Schedule.Event?

    func loadSchedule() async throws {
        do {
            let schedule = try await URLSession.awaitConnectivity.decode(
                Requests.schedule,
                dateDecodingStrategy: Requests.defaultDateDecodingStratergy
            )
            await updateSchedule(schedule)

            do {
                let data = try PropertyListEncoder().encode(slots)
                UserDefaults(suiteName: "group.uk.co.swiftleeds")?.setValue(data, forKey: "Slots")
            } catch {
                throw(error)
            }
        } catch {
            throw error
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

        let individualDates = Set(schedule.data.slots.compactMap { $0.date?.withoutTimeAtConferenceVenue }).sorted(by: (<))
        days = individualDates.map { Helper.shortDateFormatter.string(from: $0) }

        for date in individualDates {
            let key = Helper.shortDateFormatter.string(from: date)
            slots[key] = schedule.data.slots
                .filter { Calendar.current.compare(date, to: $0.date ?? Date(), toGranularity: .day) == .orderedSame }
                .sorted { $0.startTime < $1.startTime }
        }

        hasLoaded = true
    }

    private func reloadSchedule() async throws {
        guard let currentEvent else { return }

        let schedule = try await URLSession.awaitConnectivity.decode(Requests.schedule(for: currentEvent.id), dateDecodingStrategy: Requests.defaultDateDecodingStratergy, filename: "schedule-\(currentEvent.id.uuidString)")
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
