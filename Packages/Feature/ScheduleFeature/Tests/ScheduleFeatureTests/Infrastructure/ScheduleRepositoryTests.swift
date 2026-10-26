import Dependencies
import Foundation
import ScheduleDomain
import ScheduleInfrastructure
import Testing

@Suite struct ScheduleRepositoryTests {
    /// A spy that holds schedules in memory and serves them through the local store's ports.
    private final class LocalScheduleStoreSpy: @unchecked Sendable {
        /// The lock that guards `entries`.
        private let lock = NSLock()

        /// The stored schedules, by the request each answers.
        private var entries: [ScheduleRequest: StoredSchedule] = [:]

        /// The local store that reads and writes the held schedules.
        var store: LocalScheduleStore {
            LocalScheduleStore(
                load: { [self] request in lock.withLock { entries[request] } },
                save: { [self] stored, request in lock.withLock { entries[request] = stored } },
            )
        }

        /// Holds a schedule as if it were already stored.
        ///
        /// - Parameters:
        ///   - schedule: The schedule to hold.
        ///   - request: The request the schedule answers.
        ///   - storedAt: When the schedule counts as stored.
        func hold(_ schedule: Schedule, for request: ScheduleRequest, at storedAt: Date) {
            lock.withLock { entries[request] = StoredSchedule(schedule: schedule, storedAt: storedAt) }
        }

        /// Returns the schedule held for a request.
        ///
        /// - Parameter request: The request to look up.
        /// - Returns: The held schedule, or `nil` if none answers the request.
        func saved(for request: ScheduleRequest) -> Schedule? {
            lock.withLock { entries[request]?.schedule }
        }
    }

    /// A spy that records each request and answers every one with the same schedule.
    private final class RemoteScheduleStoreSpy: @unchecked Sendable {
        /// The lock that guards `recorded`.
        private let lock = NSLock()

        /// The requests received so far, in order.
        private var recorded: [ScheduleRequest] = []

        /// The schedule returned for every request.
        private let answer: Schedule

        /// Creates a spy that answers every request with one schedule.
        ///
        /// - Parameter answer: The schedule to return for every request.
        init(answering answer: Schedule) {
            self.answer = answer
        }

        /// The requests received so far, in order.
        var requests: [ScheduleRequest] {
            lock.withLock { recorded }
        }

        /// The remote store that records each request and returns the answer.
        var store: RemoteScheduleStore {
            RemoteScheduleStore(
                fetch: { [self] request async -> Schedule in
                    lock.withLock { recorded.append(request) }
                    return answer
                }
            )
        }
    }

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

private let now = Date(timeIntervalSince1970: 1_000_000)  // swiftlint:disable:this no_magic_numbers - fixture data

/// Two days, in seconds.
private let twoDays: TimeInterval = 172_800

extension RemoteScheduleStore {
    fileprivate static func failing(with error: ScheduleFetchError) -> RemoteScheduleStore {
        RemoteScheduleStore(
            fetch: { _ async throws(ScheduleFetchError) -> Schedule in throw error }
        )
    }
}
