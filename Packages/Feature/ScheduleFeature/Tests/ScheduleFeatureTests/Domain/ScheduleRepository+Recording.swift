import ScheduleDomain

extension ScheduleRepository {
    /// Creates a repository that records each event asked for and answers with one schedule.
    ///
    /// - Parameters:
    ///   - recorder: The recorder that receives each event asked for.
    ///   - answer: The schedule returned for every call.
    /// - Returns: A repository that records into `recorder` and returns `answer`.
    static func recording(
        into recorder: EventRecorder,
        answering answer: Schedule,
    ) -> ScheduleRepository {
        ScheduleRepository(
            fetchCurrentSchedule: { () async -> Schedule in
                await recorder.record(nil)
                return answer
            },
            fetchSchedule: { event async -> Schedule in
                await recorder.record(event)
                return answer
            },
        )
    }
}
