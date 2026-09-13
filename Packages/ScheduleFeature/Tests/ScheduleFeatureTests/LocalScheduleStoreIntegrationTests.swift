import Foundation
import ScheduleFeature
import Testing

// Drives the live store against a real UserDefaults suite.
@Suite struct LocalScheduleStoreIntegrationTests {
    @Test func whenTheCurrentScheduleIsSaved_shouldLoadItBack() throws {
        let suite = TemporarySuite()
        let sut = LocalScheduleStore.appGroup(suite.identifier)

        sut.save(try .fixture(eventNamed: "SwiftLeeds 2026"), for: .current)

        let loaded = try #require(sut.load(.current))
        #expect(loaded.schedule.data.event.name == "SwiftLeeds 2026")
    }

    @Test func whenOneConferenceIsSaved_shouldLoadItBackByItsEvent() throws {
        let suite = TemporarySuite()
        let sut = LocalScheduleStore.appGroup(suite.identifier)
        let event = UUID()

        sut.save(try .fixture(eventNamed: "SwiftLeeds 2022"), for: .event(event))

        let loaded = try #require(sut.load(.event(event)))
        #expect(loaded.schedule.data.event.name == "SwiftLeeds 2022")
    }

    @Test func whenTwoConferencesAreSaved_shouldKeepThemApart() throws {
        let suite = TemporarySuite()
        let sut = LocalScheduleStore.appGroup(suite.identifier)
        let (first, second) = (UUID(), UUID())

        sut.save(try .fixture(eventNamed: "SwiftLeeds 2022"), for: .event(first))
        sut.save(try .fixture(eventNamed: "SwiftLeeds 2023"), for: .event(second))

        #expect(try #require(sut.load(.event(first))).schedule.data.event.name == "SwiftLeeds 2022")
        #expect(try #require(sut.load(.event(second))).schedule.data.event.name == "SwiftLeeds 2023")
    }

    @Test func whenOneConferenceIsSaved_shouldNotAnswerForAnother() throws {
        let suite = TemporarySuite()
        let sut = LocalScheduleStore.appGroup(suite.identifier)

        sut.save(try .fixture(), for: .event(UUID()))

        #expect(sut.load(.current) == nil)
        #expect(sut.load(.event(UUID())) == nil)
    }

    @Test func whenNothingIsSaved_shouldLoadNothing() {
        let suite = TemporarySuite()
        let sut = LocalScheduleStore.appGroup(suite.identifier)

        #expect(sut.load(.current) == nil)
    }

    @Test func whenAScheduleIsSaved_shouldKeepTheTimeItWasStored() throws {
        let suite = TemporarySuite()
        let sut = LocalScheduleStore.appGroup(suite.identifier)
        let storedAt = Date(timeIntervalSince1970: 1_000)

        sut.save(try .fixture(), for: .current, at: storedAt)

        #expect(try #require(sut.load(.current)).storedAt == storedAt)
    }

    // The widget reads this key and this format from the shared suite. Changing either
    // empties every installed widget until the app next fetches.
    @Test func whenTheCurrentScheduleIsSaved_shouldWriteAPropertyListUnderTheScheduleKey() throws {
        let suite = TemporarySuite()
        let sut = LocalScheduleStore.appGroup(suite.identifier)

        sut.save(try .fixture(eventNamed: "SwiftLeeds 2026"), for: .current)

        let defaults = try #require(UserDefaults(suiteName: suite.name))
        let data = try #require(defaults.data(forKey: "Schedule"))
        let decoded = try PropertyListDecoder().decode(StoredSchedule.self, from: data)
        #expect(decoded.schedule.data.event.name == "SwiftLeeds 2026")
    }

    @Test func whenOneConferenceIsSaved_shouldWriteUnderItsEventKey() throws {
        let suite = TemporarySuite()
        let sut = LocalScheduleStore.appGroup(suite.identifier)
        let event = UUID()

        sut.save(try .fixture(), for: .event(event))

        let defaults = try #require(UserDefaults(suiteName: suite.name))
        #expect(defaults.data(forKey: "Schedule-\(event.uuidString)") != nil)
    }
}

private extension LocalScheduleStore {
    func save(_ schedule: Schedule, for request: ScheduleRequest, at storedAt: Date = .now) {
        save(StoredSchedule(schedule: schedule, storedAt: storedAt), request)
    }
}

// A suite of its own per test, removed when the test ends, so no test reads another's write.
private final class TemporarySuite {
    let name = "uk.co.swiftleeds.tests.\(UUID().uuidString)"

    var identifier: AppGroupIdentifier { AppGroupIdentifier(name) }

    deinit {
        UserDefaults.standard.removePersistentDomain(forName: name)
    }
}
