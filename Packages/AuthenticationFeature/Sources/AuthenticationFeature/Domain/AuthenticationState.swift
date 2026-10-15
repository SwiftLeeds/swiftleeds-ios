/// Whether a user is signed in.
public enum AuthenticationState: Equatable, Hashable, Sendable {
    /// A user is signed in, with the proof a caller can pass on.
    case signedIn(SignedInProof)

    /// No user is signed in.
    case signedOut
}
