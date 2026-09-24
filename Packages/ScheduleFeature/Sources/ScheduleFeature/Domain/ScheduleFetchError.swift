/// Why the schedule could not be read.
public enum ScheduleFetchError: Error, Equatable, Sendable {
    /// The request never reached the server.
    case couldNotReachServer

    /// The server answered, but the body did not decode into a schedule.
    case invalidResponse

    /// The server answered with a status other than 200.
    case unknown
}
