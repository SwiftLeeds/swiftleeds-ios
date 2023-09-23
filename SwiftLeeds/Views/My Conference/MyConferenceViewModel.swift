//
//  MyConferenceViewModel.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 01/08/2022.
//

import Foundation
import Combine
import NetworkKit
import SwiftUI

class MyConferenceViewModel: ObservableObject {
    @Published private(set) var event: Schedule.Event?
    @Published private(set) var days: [String] = []
    @Published private(set) var slots: [String: [Schedule.Slot]] = [:]

    @Environment(\.network) var network: Networking

    func loadSchedule() async throws {
        do {
            let schedule = try await network.performRequest(endpoint: ScheduleEndpoint())

            await MainActor.run {
                event = schedule.data.event

                let individualDates = Set(schedule.data.slots.compactMap { $0.date?.withoutTime }).sorted(by: (<))
                days = individualDates.map { Helper.shortDateFormatter.string(from: $0) }

                for date in individualDates {
                    let key = Helper.shortDateFormatter.string(from: date)
                    slots[key] = schedule.data.slots.filter { Calendar.current.compare(date, to: $0.date ?? Date(), toGranularity: .day) == .orderedSame }
                }
            }

            do {
                let data = try PropertyListEncoder().encode(slots)
                UserDefaults(suiteName: "group.uk.co.swiftleeds")?.setValue(data, forKey: "Slots")
            } catch {
                throw(error)
            }
        } catch {
            throw(error)
        }
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
}
