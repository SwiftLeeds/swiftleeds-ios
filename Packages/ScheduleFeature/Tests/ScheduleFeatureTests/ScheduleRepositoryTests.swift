import Dependencies
import Foundation
import ScheduleFeature
import Testing

@Suite struct ScheduleRepositoryTests {
    // The reported bug: offline, picking a conference the device already holds showed
    // the previous conference's schedule.
    @Test func whenTheRemoteFailsAndTheConferenceIsStored_shouldReturnTheStoredSchedule() async throws {
        let event = UUID()
        let local = LocalScheduleStoreSpy()
        local.hold(try .fixture(eventNamed: "SwiftLeeds 2022"), for: .event(event), at: now)

        let schedule = try await withDependencies {
            $0.localScheduleStore = local.store
            $0.remoteScheduleStore = .failing(with: .couldNotReachServer)
            $0.date = .constant(now)
        } operation: {
            try await ScheduleRepository.liveValue.fetchSchedule(event)
        }

        #expect(schedule.data.event.name == "SwiftLeeds 2022")
    }

    @Test func whenTheStoredScheduleIsFresh_shouldNotAskTheRemote() async throws {
        let local = LocalScheduleStoreSpy()
        local.hold(try .fixture(eventNamed: "SwiftLeeds 2026"), for: .current, at: now)
        let remote = RemoteScheduleStoreSpy(answering: try .fixture())

        _ = try await withDependencies {
            $0.localScheduleStore = local.store
            $0.remoteScheduleStore = remote.store
            $0.date = .constant(now)
        } operation: {
            try await ScheduleRepository.liveValue.fetchCurrentSchedule()
        }

        #expect(remote.requests.isEmpty)
    }

    @Test func whenTheStoredScheduleIsStale_shouldAskTheRemote() async throws {
        let local = LocalScheduleStoreSpy()
        local.hold(try .fixture(eventNamed: "SwiftLeeds 2025"), for: .current, at: now)
        let remote = RemoteScheduleStoreSpy(answering: try .fixture(eventNamed: "SwiftLeeds 2026"))

        let schedule = try await withDependencies {
            $0.localScheduleStore = local.store
            $0.remoteScheduleStore = remote.store
            $0.date = .constant(now.addingTimeInterval(twoDays))
        } operation: {
            try await ScheduleRepository.liveValue.fetchCurrentSchedule()
        }

        #expect(schedule.data.event.name == "SwiftLeeds 2026")
        #expect(remote.requests == [.current])
    }

    @Test func whenNothingIsStored_shouldSaveWhatTheRemoteAnswers() async throws {
        let event = UUID()
        let local = LocalScheduleStoreSpy()
        let remote = RemoteScheduleStoreSpy(answering: try .fixture(eventNamed: "SwiftLeeds 2023"))

        _ = try await withDependencies {
            $0.localScheduleStore = local.store
            $0.remoteScheduleStore = remote.store
            $0.date = .constant(now)
        } operation: {
            try await ScheduleRepository.liveValue.fetchSchedule(event)
        }

        #expect(local.saved(for: .event(event))?.data.event.name == "SwiftLeeds 2023")
    }

    // Selecting the live conference in the picker asks for it by id, so a current fetch
    // has to leave an entry under that id as well.
    @Test func whenTheCurrentScheduleArrives_shouldAlsoSaveItUnderItsEvent() async throws {
        let event = UUID()
        let local = LocalScheduleStoreSpy()
        let remote = RemoteScheduleStoreSpy(
            answering: try .fixture(eventNamed: "SwiftLeeds 2026", eventID: event)
        )

        _ = try await withDependencies {
            $0.localScheduleStore = local.store
            $0.remoteScheduleStore = remote.store
            $0.date = .constant(now)
        } operation: {
            try await ScheduleRepository.liveValue.fetchCurrentSchedule()
        }

        #expect(local.saved(for: .current)?.data.event.name == "SwiftLeeds 2026")
        #expect(local.saved(for: .event(event))?.data.event.name == "SwiftLeeds 2026")
    }

    @Test func whenTheRemoteFailsAndNothingIsStored_shouldThrowTheRemoteError() async {
        let local = LocalScheduleStoreSpy()

        await withDependencies {
            $0.localScheduleStore = local.store
            $0.remoteScheduleStore = .failing(with: .couldNotReachServer)
            $0.date = .constant(now)
        } operation: {
            await #expect(throws: ScheduleFetchError.couldNotReachServer) {
                try await ScheduleRepository.liveValue.fetchCurrentSchedule()
            }
        }
    }

    @Test func whenTheRemoteFails_shouldNotServeAStaleSchedule() async throws {
        let local = LocalScheduleStoreSpy()
        local.hold(try .fixture(eventNamed: "SwiftLeeds 2025"), for: .current, at: now)

        await withDependencies {
            $0.localScheduleStore = local.store
            $0.remoteScheduleStore = .failing(with: .couldNotReachServer)
            $0.date = .constant(now.addingTimeInterval(twoDays))
        } operation: {
            await #expect(throws: ScheduleFetchError.couldNotReachServer) {
                try await ScheduleRepository.liveValue.fetchCurrentSchedule()
            }
        }
    }
}

private let now = Date(timeIntervalSince1970: 1_000_000)
private let twoDays: TimeInterval = 60 * 60 * 24 * 2

private extension RemoteScheduleStore {
    static func failing(with error: ScheduleFetchError) -> RemoteScheduleStore {
        RemoteScheduleStore(
            fetch: { _ async throws(ScheduleFetchError) -> Schedule in throw error }
        )
    }
}

// Both ports are synchronous at the call site, so a lock records the calls rather than an actor.
private final class LocalScheduleStoreSpy: @unchecked Sendable {
    private let lock = NSLock()
    private var entries: [ScheduleRequest: StoredSchedule] = [:]

    func hold(_ schedule: Schedule, for request: ScheduleRequest, at storedAt: Date) {
        lock.withLock { entries[request] = StoredSchedule(schedule: schedule, storedAt: storedAt) }
    }

    func saved(for request: ScheduleRequest) -> Schedule? {
        lock.withLock { entries[request]?.schedule }
    }

    var store: LocalScheduleStore {
        LocalScheduleStore(
            load: { [self] request in lock.withLock { entries[request] } },
            save: { [self] stored, request in lock.withLock { entries[request] = stored } }
        )
    }
}

private final class RemoteScheduleStoreSpy: @unchecked Sendable {
    private let lock = NSLock()
    private var recorded: [ScheduleRequest] = []
    private let answer: Schedule

    init(answering answer: Schedule) {
        self.answer = answer
    }

    var requests: [ScheduleRequest] {
        lock.withLock { recorded }
    }

    var store: RemoteScheduleStore {
        RemoteScheduleStore(
            fetch: { [self] request async throws(ScheduleFetchError) -> Schedule in
                lock.withLock { recorded.append(request) }
                return answer
            }
        )
    }
}
