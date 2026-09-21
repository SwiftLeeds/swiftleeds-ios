/// A reason the team could not be fetched.
public enum TeamFetchError: Error, Equatable {
    /// The request never arrived. A device with no connection and a server that is
    /// down are not told apart.
    case couldNotReachServer

    /// The server answered, but not with something we accept.
    case invalidResponse

    /// Any other failure, including a status other than 200 OK.
    case unknown
}
