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
