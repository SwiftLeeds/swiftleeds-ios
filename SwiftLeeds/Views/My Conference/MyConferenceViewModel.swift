//
//  MyConferenceViewModel.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 01/08/2022.
//

import Foundation
import Combine
import NetworkKit

class MyConferenceViewModel: ObservableObject {
    @Published var event: Schedule.Event?
    @Published var slots: [Schedule.Slot] = []

    @MainActor
    func loadSchedule() async throws {
        do {
            let network = Network(environment: SwiftLeedsEnvironment())
            let schedule = try await network.performRequest(endpoint: ScheduleEndpoint())
            self.event = schedule.data.event
            self.slots = schedule.data.slots
        } catch {
            throw(error)
        }
    }

    var numberOfDaysToConference: Int? {
        guard let conferenceDate = event?.date else { return nil }

        let days = Calendar.current.numberOfDays(to: conferenceDate)

        if days > 0 {
            return days
        } else {
            return days
        }
    }

    static let stringDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }()
}
