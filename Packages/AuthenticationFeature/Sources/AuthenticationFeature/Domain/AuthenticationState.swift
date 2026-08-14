public enum AuthenticationState: Equatable, Hashable, Sendable {
    case signedIn(SignedInProof)
    case signedOut
}
