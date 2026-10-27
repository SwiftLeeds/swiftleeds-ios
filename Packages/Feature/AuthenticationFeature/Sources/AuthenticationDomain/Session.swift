/// Proof that a user is signed in.
package struct Session: Equatable, Hashable, Sendable {
    /// The session's token.
    package let token: SessionToken

    /// Creates a session.
    package init(token: SessionToken) {
        self.token = token
    }
}
