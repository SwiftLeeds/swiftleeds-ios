import Foundation
import ScheduleFeature

extension Schedule {
    static func fixture(
        eventNamed name: String = "SwiftLeeds 2026",
        eventID: UUID = UUID()
    ) throws -> Schedule {
        Schedule(
            data: try Schedule.Data(
                event: .fixture(named: name, id: eventID),
                events: [.fixture(named: name, id: eventID)],
                days: [
                    Schedule.Day(
                        date: Date(timeIntervalSince1970: 0),
                        name: "Day 1",
                        slots: [
                            Schedule.Slot(
                                id: UUID(),
                                date: Date(timeIntervalSince1970: 0),
                                startTime: "09:45",
                                duration: 30,
                                activity: .lunch,
                                presentation: nil
                            ),
                        ]
                    ),
                ]
            )
        )
    }
}

extension Schedule.Event {
    static func fixture(
        named name: String = "SwiftLeeds 2026",
        id: UUID = UUID()
    ) -> Schedule.Event {
        Schedule.Event(
            id: id,
            name: name,
            location: "The Playhouse, Leeds",
            date: Date(timeIntervalSince1970: 0)
        )
    }
}
