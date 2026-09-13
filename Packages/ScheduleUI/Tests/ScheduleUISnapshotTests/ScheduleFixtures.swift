#if os(iOS)
import Foundation
import ScheduleFeature

// Every profile image is empty, so a cell draws its placeholder rather than waiting
// on the network, which would make each snapshot a race.
extension Speaker {
    static let withTwitter = Speaker(
        id: UUID(),
        name: "Alex Fletcher",
        biography: "Writes about Swift, Core Data and concurrency.",
        profileImage: "",
        organisation: "Leeds Software Co",
        twitter: "alexfletcher"
    )

    static let withoutTwitter = Speaker(
        id: UUID(),
        name: "Sam Oduya",
        biography: "Builds reading apps and speaks about accessibility.",
        profileImage: "",
        organisation: "Northern Apps",
        twitter: nil
    )
}

extension Presentation {
    static let oneSpeaker = Presentation(
        id: UUID(),
        title: "Practical Swift concurrency",
        synopsis: "What actors buy you, and what they cost.",
        speakers: [.withTwitter],
        image: nil,
        slidoURL: "https://app.sli.do/event/example",
        videoURL: nil
    )

    static let twoSpeakers = Presentation(
        id: UUID(),
        title: "Accessibility, end to end",
        synopsis: "Shipping an app that everybody can use.",
        speakers: [.withTwitter, .withoutTwitter],
        image: nil,
        slidoURL: nil,
        videoURL: "https://www.youtube.com/watch?v=example"
    )
}

extension Activity {
    static let coffeeBreak = Activity(
        id: UUID(),
        title: "Coffee break",
        subtitle: "Stretch your legs",
        description: "The atrium has coffee, tea and something to eat.",
        image: nil,
        metadataURL: nil
    )
}

extension Schedule.Event {
    static func fixture(named name: String = "SwiftLeeds 2026") -> Schedule.Event {
        Schedule.Event(
            id: UUID(),
            name: name,
            location: "The Playhouse, Leeds",
            date: Date(timeIntervalSince1970: 0)
        )
    }
}

extension Schedule.Day {
    static func fixture(named name: String) -> Schedule.Day {
        Schedule.Day(
            date: Date(timeIntervalSince1970: 0),
            name: name,
            slots: [
                .fixture(startTime: "09:30", presentation: .oneSpeaker),
                .fixture(startTime: "10:30", activity: .coffeeBreak),
                .fixture(startTime: "11:00", presentation: .twoSpeakers),
            ]
        )
    }
}

extension Schedule.Slot {
    static func fixture(
        startTime: String,
        activity: Activity? = nil,
        presentation: Presentation? = nil
    ) -> Schedule.Slot {
        Schedule.Slot(
            id: UUID(),
            date: Date(timeIntervalSince1970: 0),
            startTime: startTime,
            duration: 45,
            activity: activity,
            presentation: presentation
        )
    }
}
#endif
