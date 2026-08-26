public enum AttendeeFetchError: Error, Equatable {
    case unauthorized

    /// The request never reached the server.
    ///
    /// Does not distinguish a device with no connection from a server that is down.
    case couldNotReachServer

    /// The server answered, but not with something we accept.
    case invalidResponse

    case unknown
}
