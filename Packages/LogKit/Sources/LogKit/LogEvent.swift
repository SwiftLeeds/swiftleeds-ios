/// Everything recorded about one logged occurrence.
public struct LogEvent: Hashable, Sendable {
    public let level: LogLevel
    public let category: LogCategory
    public let message: MessageTemplate
    public let fields: LogFields
    public let source: SourceLocation

    /// Creates an event, recording where it was raised.
    ///
    /// `source` defaults to this initializer's own call site, so build the event where the
    /// occurrence happened, or pass a location captured there.
    public init(
        level: LogLevel,
        category: LogCategory,
        message: MessageTemplate,
        fields: LogFields = LogFields(),
        source: SourceLocation = .here()
    ) {
        self.level = level
        self.category = category
        self.message = message
        self.fields = fields
        self.source = source
    }
}
