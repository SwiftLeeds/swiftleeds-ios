extension HTTPClient {
    public static func live(onSessionExpiry: @escaping @Sendable () async -> Void) -> HTTPClient {
        urlSession()
            .logging()
            .interceptingSessionExpiry(onExpiry: onSessionExpiry)
            .authenticated()
    }
}
