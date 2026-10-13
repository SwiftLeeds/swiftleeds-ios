/// Proof that a user is signed in. Sealed so only this package can mint one.
package struct Session: Equatable, Hashable, Sendable {
    package let token: SessionToken

    package init(token: SessionToken) {
        self.token = token
    }
}
