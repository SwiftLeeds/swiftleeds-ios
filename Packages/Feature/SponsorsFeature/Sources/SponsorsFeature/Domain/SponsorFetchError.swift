public enum SponsorFetchError: Error, Equatable {
    /// The request never arrived. A device with no connection and a server that is
    /// down are not told apart.
    case couldNotReachServer

    /// The server answered, but not with something we accept.
    case invalidResponse

    case unknown
}
