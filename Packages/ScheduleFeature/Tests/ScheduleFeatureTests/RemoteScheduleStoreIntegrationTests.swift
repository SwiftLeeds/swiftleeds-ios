import Dependencies
import Foundation
import NetworkKit
import ScheduleFeature
import Testing

// Drives the live store with only the transport stubbed.
@Suite struct RemoteScheduleStoreIntegrationTests {
    @Test func whenNoEventIsGiven_shouldSendNoEventQueryItem() async throws {
        let recorder = RequestRecorder()

        _ = try await withDependencies {
            $0.httpClient = .recordingRequests(into: recorder, responding: ScheduleJSON.valid)
        } operation: {
            try await RemoteScheduleStore.liveValue.fetch(.current)
        }

        let url = try #require(await recorder.requests.first?.url?.absoluteString)
        #expect(url.contains("event=") == false)
    }

    @Test func whenAnEventIsGiven_shouldSendItsIdAsAQueryItem() async throws {
        let recorder = RequestRecorder()
        let event = UUID()

        _ = try await withDependencies {
            $0.httpClient = .recordingRequests(into: recorder, responding: ScheduleJSON.valid)
        } operation: {
            try await RemoteScheduleStore.liveValue.fetch(.event(event))
        }

        let url = try #require(await recorder.requests.first?.url?.absoluteString)
        #expect(url.contains("event=\(event.uuidString)"))
    }

    @Test func whenServerAnswersWell_shouldReturnTheDaysAndSlots() async throws {
        let schedule = try await withDependencies {
            $0.httpClient = .responding(with: ScheduleJSON.valid, statusCode: 200)
        } operation: {
            try await RemoteScheduleStore.liveValue.fetch(.current)
        }

        #expect(schedule.data.event.name == "SwiftLeeds 2026")
        #expect(schedule.data.days.count == 1)
        #expect(schedule.data.days.first?.slots.count == 2)
    }

    @Test func whenServerCannotBeReached_shouldThrowCouldNotReachServer() async {
        await withDependencies {
            $0.httpClient = .failing(with: URLError(.notConnectedToInternet))
        } operation: {
            await #expect(throws: ScheduleFetchError.couldNotReachServer) {
                try await RemoteScheduleStore.liveValue.fetch(.current)
            }
        }
    }

    @Test func whenServerAnswersWithAnErrorStatus_shouldThrowUnknown() async {
        await withDependencies {
            $0.httpClient = .responding(with: ScheduleJSON.valid, statusCode: 500)
        } operation: {
            await #expect(throws: ScheduleFetchError.unknown) {
                try await RemoteScheduleStore.liveValue.fetch(.current)
            }
        }
    }

    @Test func whenBodyCannotBeDecoded_shouldThrowInvalidResponse() async {
        await withDependencies {
            $0.httpClient = .responding(with: Data("not json".utf8), statusCode: 200)
        } operation: {
            await #expect(throws: ScheduleFetchError.invalidResponse) {
                try await RemoteScheduleStore.liveValue.fetch(.current)
            }
        }
    }

    // A conference does not have an empty schedule, so an empty days array is a bad payload.
    @Test func whenTheScheduleHasNoDays_shouldThrowInvalidResponse() async {
        await withDependencies {
            $0.httpClient = .responding(with: ScheduleJSON.noDays, statusCode: 200)
        } operation: {
            await #expect(throws: ScheduleFetchError.invalidResponse) {
                try await RemoteScheduleStore.liveValue.fetch(.current)
            }
        }
    }

    @Test func whenASlotCarriesNoContent_shouldThrowInvalidResponse() async {
        await withDependencies {
            $0.httpClient = .responding(with: ScheduleJSON.slotWithNoContent, statusCode: 200)
        } operation: {
            await #expect(throws: ScheduleFetchError.invalidResponse) {
                try await RemoteScheduleStore.liveValue.fetch(.current)
            }
        }
    }
}
