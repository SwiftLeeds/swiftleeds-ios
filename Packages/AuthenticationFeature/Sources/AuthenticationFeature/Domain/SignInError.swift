/// Why signing in did not succeed.
///
/// Deliberately coarse: a case exists only where a caller would behave differently.
public enum SignInError: Error, Equatable {
    /// The email address and ticket reference did not match a ticket.
    case invalidCredentials

    /// The request never reached the server.
    ///
    /// Does not distinguish a device with no connection from a server that is down.
    case couldNotReachServer

    case unknown
}
