import LogKit

extension LogEvent {
    /// Returns an event for a test, defaulting the parts the caller omits.
    ///
    /// - Parameters:
    ///   - message: The message the event carries.
    ///   - level: The severity the event is recorded at.
    ///   - category: The area of the app the event came from.
    /// - Returns: An event whose source is this helper, not the calling test.
    package static func stub(
        _ message: MessageTemplate = "event",
        level: LogLevel = .info,
        category: LogCategory = "test"
    ) -> LogEvent {
        LogEvent(level: level, category: category, message: message, source: .here())
    }
}
