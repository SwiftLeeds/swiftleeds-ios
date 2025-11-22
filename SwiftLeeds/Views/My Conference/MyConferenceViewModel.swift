import Foundation
import Combine
import Networking
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

private extension Requests {
    static let schedule = Request<Schedule>(
        host: host,
        path: "\(apiVersion2)/schedule",
        eTagKey: "etag-schedule"
    )

    static func schedule(for eventID: UUID) -> Request<Schedule> {
        Request<Schedule>(
            host: host,
            path: "\(apiVersion2)/schedule",
            method: .get([.init(
                name: "event",
                value: eventID.uuidString)
            ]),
            eTagKey: "etag-schedule-\(eventID.uuidString)"
        )
    }

    // Custom strategy for v2 schedule endpoint (handles both ISO8601 and dd-MM-yyyy)
    static var scheduleDateDecodingStrategy: JSONDecoder.DateDecodingStrategy = {
        return .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO8601 first (for slot dates)
            if let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            }

            // Fallback to dd-MM-yyyy format (for event dates)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            if let date = formatter.date(from: dateString) {
                return date
            }

            // If neither works, throw an error
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Date string does not match expected format. Expected ISO8601 or dd-MM-yyyy, got: \(dateString)"
            )
        }
    }()
}
