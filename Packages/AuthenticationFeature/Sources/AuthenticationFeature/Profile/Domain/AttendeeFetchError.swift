public enum AttendeeFetchError: Error, Equatable {
    case unauthorized
    /// The server answered, but not with something we accept.
    case invalidResponse
    case unknown
}
