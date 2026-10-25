import LogKit

extension LogEvent {
    /// Returns an event for a test.
    ///
    /// ```swift
    /// let event = LogEvent.stub("signed in", level: .notice)
    /// ```
    ///
    /// - Parameters:
    ///   - message: The message the event carries. Defaults to `"event"`.
    ///   - level: The severity the event is recorded at. Defaults to `.info`.
    ///   - category: The area of the app the event came from. Defaults to `"test"`.
    /// - Returns: An event whose source is this stub's line. A test that asserts `source` sees the stub's
    ///   location.
    package static func stub(
        _ message: MessageTemplate = "event",
        level: LogLevel = .info,
        category: LogCategory = "test",
    ) -> LogEvent {
        LogEvent(level: level, category: category, message: message, source: .here())
    }
}
