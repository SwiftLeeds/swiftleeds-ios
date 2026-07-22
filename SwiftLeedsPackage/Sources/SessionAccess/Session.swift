import Foundation

public struct Session: Equatable, Hashable, Sendable {
    // `init` is intentionally internal to prevent creation
    // of a `Session` outside of the `SessionAccess` module.
    //
    // An instance of `Session` becomes a proof that a user
    // is logged in.
    //
    // DO NOT MAKE THIS INIT PUBLIC
    #warning("Temporarily `public` to test architectural approach")
    public init() {}
}
