/// A reason the attendee could not be fetched.
public enum AttendeeFetchError: Error, Equatable {
    /// The server refused the session, answering 401 Unauthorized.
    case unauthorized

    /// The request never reached the server.
    ///
    /// Does not distinguish a device with no connection from a server that is down.
    case couldNotReachServer

    /// The server answered 200 OK, but with a body we cannot read.
    case invalidResponse

    /// Any other failure, including a status other than 200 OK or 401.
    case unknown
}
