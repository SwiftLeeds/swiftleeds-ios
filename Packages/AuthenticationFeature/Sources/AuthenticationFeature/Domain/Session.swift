/// Proof that a user is signed in. Sealed so only `AuthenticationFeature` can mint one.
package struct Session: Equatable, Hashable, Sendable {
    package let token: SessionToken

    package init(_ token: SessionToken) {
        self.token = token
    }
}
