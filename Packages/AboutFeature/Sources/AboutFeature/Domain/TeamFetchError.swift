public enum TeamFetchError: Error, Equatable {
    /// The request never arrived. A device with no connection and a server that is
    /// down are not told apart.
    case couldNotReachServer

    case unknown
}
