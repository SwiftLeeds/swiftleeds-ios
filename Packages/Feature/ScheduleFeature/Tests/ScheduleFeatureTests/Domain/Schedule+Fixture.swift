import Foundation
import ScheduleDomain
import ScheduleDomainTestSupport

extension Schedule {
    static func fixture(
        eventNamed name: String = "SwiftLeeds 2026",
        eventID: UUID = UUID(),
    ) throws -> Self {
        Self(
            data: try Self.Data(
                event: .fixture(named: name, id: eventID),
                events: [.fixture(named: name, id: eventID)],
                days: [
                    Self.Day(
                        date: Date(timeIntervalSince1970: 0),
                        name: "Day 1",
                        slots: [
                            Self.Slot(
                                id: UUID(),
                                date: Date(timeIntervalSince1970: 0),
                                startTime: "09:45",
                                duration: 30,  // swiftlint:disable:this no_magic_numbers - fixture data
                                activity: .lunch,
                                presentation: nil,
                            )
                        ],
                    )
                ],
            )
        )
    }
}
