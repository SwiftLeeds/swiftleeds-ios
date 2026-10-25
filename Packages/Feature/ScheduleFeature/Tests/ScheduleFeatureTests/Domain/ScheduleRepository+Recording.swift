import ScheduleDomain

extension ScheduleRepository {
    /// Creates a repository that records each event asked for and answers with one schedule.
    ///
    /// - Parameters:
    ///   - spy: The spy that receives each event asked for.
    ///   - answer: The schedule returned for every call.
    /// - Returns: A repository that records into `spy` and returns `answer`.
    static func recording(
        into spy: ScheduleRepositorySpy,
        answering answer: Schedule,
    ) -> ScheduleRepository {
        ScheduleRepository(
            fetchCurrentSchedule: { () async -> Schedule in
                await spy.record(nil)
                return answer
            },
            fetchSchedule: { event async -> Schedule in
                await spy.record(event)
                return answer
            },
        )
    }
}
