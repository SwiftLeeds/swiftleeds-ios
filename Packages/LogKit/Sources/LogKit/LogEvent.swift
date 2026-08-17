/// Everything recorded about one logged occurrence.
public struct LogEvent: Hashable, Sendable {
    public let level: LogLevel
    public let category: LogCategory
    public let message: MessageTemplate
    public let fields: LogFields
    public let source: SourceLocation

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
