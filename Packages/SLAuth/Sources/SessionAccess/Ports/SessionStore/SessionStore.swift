#warning("Rename `SessionStore`")
package struct SessionStore: Sendable {
    package var establish: @Sendable () -> Void
    package var clear: @Sendable () -> Void
    // package var currentToken: @Sendable () async -> SessionToken? // for the auth-header interceptor
}
