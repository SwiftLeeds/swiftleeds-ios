import Dependencies
import LogKit
import SponsorsFeature
import Testing

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

    @Test func whenOutcomesDiffer_shouldLogDifferentMessages() throws {
        let messages = try [
            #require(try mappedEvent(for: SponsorListDTO(data: [.fixture()]))),
            #require(refusedEvent(for: SponsorListDTO(data: [.fixture(sponsorLevel: "bronze")]))),
        ].map(\.message)

        #expect(Set(messages).count == messages.count)
    }

    @Test func whenLogIsOverriddenAfterBuilding_shouldWriteToTheOverride() throws {
        let recorder = LogRecorder()
        let sut = SponsorMapper.live.logging()

        try withDependencies {
            $0.log = recorder.log
        } operation: {
            _ = try sut.map(SponsorListDTO(data: [.fixture()]))
        }

        #expect(recorder.events.count == 1)
    }

    private func mappedEvent(for list: SponsorListDTO) throws -> LogEvent? {
        let recorder = LogRecorder()

        try withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = SponsorMapper.live.logging()
            _ = try sut.map(list)
        }

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

        #expect(recorder.events.count == 1)
        return recorder.events.first
    }
}
