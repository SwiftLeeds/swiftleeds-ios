/// A reason the location categories could not be fetched.
public enum LocationCategoryFetchError: Error, Equatable {
    /// The request never arrived. A device with no connection and a server that is
    /// down are not told apart.
    case couldNotReachServer

    /// The server answered 200 OK, but with a body we cannot read.
    case invalidResponse

    /// Any other failure, including a status other than 200 OK.
    case unknown
}
