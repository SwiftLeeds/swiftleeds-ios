import Dependencies
import LogKit
import SponsorsFeature
import Testing

/// The public `SponsorFetchError` is deliberately bare, so these assert the reason survives to the
/// log even though the caller never sees it.
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

    /// A list is mapped every time the sponsors screen loads, so it records at the level the
    /// platform drops unless someone is watching.
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
