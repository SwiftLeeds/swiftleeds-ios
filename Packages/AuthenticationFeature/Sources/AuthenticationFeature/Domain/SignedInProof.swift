/// A token-free, un-forgeable capability proving its holder is signed in.
/// Only `AuthenticationFeature` can mint one (the `init` is `package`), so possession is proof.
public struct SignedInProof: Equatable, Hashable, Sendable {
    package init() {}
}
