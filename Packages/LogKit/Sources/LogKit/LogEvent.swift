/// Everything recorded about one logged occurrence.
public struct LogEvent: Hashable, Sendable {
    /// How severe the occurrence was.
    public let level: LogLevel

    /// The area of the app the occurrence came from.
    public let category: LogCategory

    /// The message, with its gaps still separate from its literal text.
    public let message: MessageTemplate

    /// The fields recorded beside the message, in order.
    public let fields: LogFields

    /// Where in the source the event was logged.
    public let source: SourceLocation

    /// Creates an event, carrying no fields unless some are given.
    ///
    /// - Parameters:
    ///   - level: How severe the occurrence was.
    ///   - category: The area of the app the occurrence came from.
    ///   - message: The message, with its gaps still separate.
    ///   - fields: The fields recorded beside the message, in order.
    ///   - source: Where in the source the event was logged.
    public init(
        level: LogLevel,
        category: LogCategory,
        message: MessageTemplate,
        fields: LogFields = LogFields(),
        source: SourceLocation
    ) {
        self.level = level
        self.category = category
        self.message = message
        self.fields = fields
        self.source = source
    }
}
