/// Why the schedule could not be read.
public enum ScheduleFetchError: Error, Equatable, Sendable {
    case couldNotReachServer
    case invalidResponse
    case unknown
}
