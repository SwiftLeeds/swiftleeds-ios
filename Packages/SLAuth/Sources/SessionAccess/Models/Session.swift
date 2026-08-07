public struct Session: Equatable, Hashable, Sendable {
    package let token: SessionToken

    // `init` is intentionally `package` access control to prevent
    // creation of a `Session` outside of the `SessionAccess`
    // module.
    //
    // An instance of `Session` becomes a proof that a user is
    // logged in.
    //
    // DO NOT MAKE THIS INIT PUBLIC
    package init(
        _ token: SessionToken
    ) {
        self.token = token
    }
}
