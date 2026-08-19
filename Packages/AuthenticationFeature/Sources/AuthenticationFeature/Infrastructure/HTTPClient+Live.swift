extension HTTPClient {
    public static func live(onSessionExpiry: @escaping @Sendable () async -> Void) -> HTTPClient {
        urlSession()
            .loggingFailures()
            .interceptingSessionExpiry(onExpiry: onSessionExpiry)
            .authenticated()
    }
}
