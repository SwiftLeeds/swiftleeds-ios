/// A token-free, un-forgeable capability proving its holder is signed in.
/// Minting requires a `Session` (evidence of a real sign-in, which only `AuthenticationFeature`
/// can produce), but the session is not retained, so the proof carries no token.
public struct SignedInProof: Equatable, Hashable, Sendable {
    package init(_: Session) {}

    #if DEBUG
    /// Test and preview only: mints a proof without a session so callers outside
    /// `AuthenticationFeature` can construct a signed-in state. Absent from release builds.
    public init() {}
    #endif
}
