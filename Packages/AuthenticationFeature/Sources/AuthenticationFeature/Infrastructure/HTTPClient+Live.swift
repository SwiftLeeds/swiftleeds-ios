extension HTTPClient {
    public static func live(onSessionExpiry: @escaping @Sendable () async -> Void) -> HTTPClient {
        urlSession()
            .interceptingSessionExpiry(onExpiry: onSessionExpiry)
            .authenticated()
    }
}
