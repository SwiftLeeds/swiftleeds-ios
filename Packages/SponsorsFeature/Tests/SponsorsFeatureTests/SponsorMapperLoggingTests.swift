import Dependencies
import LogKit
import SponsorsFeature
import Testing

// The caller never sees why a list was refused. These assert the reason reaches the log.
@Suite struct SponsorMapperLoggingTests {
    @Test func whenLevelIsUnknown_shouldLogAtErrorLevel() throws {
        let list = SponsorListDTO(data: [.fixture(name: "Bronze Co", sponsorLevel: "bronze")])

        let event = try #require(refusedEvent(for: list))

        #expect(event.level == .error)
    }

    @Test func whenLevelIsUnknown_shouldLogSponsorName() throws {
        let list = SponsorListDTO(data: [.fixture(name: "Bronze Co", sponsorLevel: "bronze")])

        let event = try #require(refusedEvent(for: list))

        #expect(event.fields.first { String($0.name) == "sponsor" }?.value == .string("Bronze Co"))
    }

    @Test func whenLevelIsUnknown_shouldLogFieldName() throws {
        let list = SponsorListDTO(data: [.fixture(name: "Bronze Co", sponsorLevel: "bronze")])

        let event = try #require(refusedEvent(for: list))

        #expect(event.fields.first { String($0.name) == "field" }?.value == .string("sponsorLevel"))
    }

    @Test func whenLevelIsUnknown_shouldLogRefusedValue() throws {
        let list = SponsorListDTO(data: [.fixture(name: "Bronze Co", sponsorLevel: "bronze")])

        let event = try #require(refusedEvent(for: list))

        #expect(event.fields.first { String($0.name) == "value" }?.value == .string("bronze"))
    }

    // A list is mapped every time the sponsors screen loads, so it records at the level the
    // platform drops unless someone is watching.
    @Test func whenListMaps_shouldLogAtDebugLevel() throws {
        let list = SponsorListDTO(data: [.fixture(id: "a"), .fixture(id: "b")])

        let event = try #require(try mappedEvent(for: list))

        #expect(event.level == .debug)
    }

    @Test func whenListMaps_shouldLogSponsorCount() throws {
        let list = SponsorListDTO(data: [.fixture(id: "a"), .fixture(id: "b")])

        let event = try #require(try mappedEvent(for: list))

        #expect(event.fields.first { String($0.name) == "count" }?.value == .integer(2))
    }

    @Test func whenListIsRefused_shouldRethrowMappingError() {
        let list = SponsorListDTO(data: [.fixture(name: "Bronze Co", sponsorLevel: "bronze")])

        withDependencies {
            $0.log = LogRecorder().log
        } operation: {
            let sut = SponsorMapper.live.logging()

            #expect(throws: SponsorMapper.MappingError.self) {
                try sut.map(list)
            }
        }
    }

    // A destination groups by message, so two outcomes sharing one message could never be told
    // apart when filtering.
    @Test func whenOutcomesDiffer_shouldLogDifferentMessages() throws {
        let messages = try [
            #require(try mappedEvent(for: SponsorListDTO(data: [.fixture()]))),
            #require(refusedEvent(for: SponsorListDTO(data: [.fixture(sponsorLevel: "bronze")]))),
        ].map(\.message)

        #expect(Set(messages).count == messages.count)
    }

    private func mappedEvent(for list: SponsorListDTO) throws -> LogEvent? {
        let recorder = LogRecorder()

        try withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = SponsorMapper.live.logging()
            _ = try sut.map(list)
        }

        // Pinned here rather than per test, so a decorator that logs an outcome twice fails
        // everything rather than nothing.
        #expect(recorder.events.count == 1)
        return recorder.events.first
    }

    private func refusedEvent(for list: SponsorListDTO) -> LogEvent? {
        let recorder = LogRecorder()

        withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = SponsorMapper.live.logging()
            _ = try? sut.map(list)
        }

        // Pinned here rather than per test, so a decorator that logs an outcome twice fails
        // everything rather than nothing.
        #expect(recorder.events.count == 1)
        return recorder.events.first
    }
}
