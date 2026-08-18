/// Why signing in did not succeed, in the terms a caller can act on.
///
/// Deliberately coarse: a case exists only where the UI would say something different. Anything a
/// user cannot act on stays ``unknown``, and the detail goes to the log instead.
public enum SignInError: Error, Equatable {
    /// The email address and ticket reference did not match a ticket.
    case invalidCredentials

    /// The request never reached the server.
    ///
    /// Named for what we know: this cannot tell a device with no connection from a server that is
    /// down, so it must not claim the user is offline.
    case couldNotReachServer

    case unknown
}
