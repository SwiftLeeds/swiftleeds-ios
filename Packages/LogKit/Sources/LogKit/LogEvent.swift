/// Everything recorded about one logged occurrence.
public struct LogEvent: Hashable, Sendable {
    public let level: LogLevel
    public let category: LogCategory
    public let message: MessageTemplate
    public let fields: LogFields
    public let source: SourceLocation

    /// Creates an event.
    ///
    /// Pass `source: .here()` from where the occurrence happened. The default expands inside this
    /// file, so it records this initializer rather than the caller.
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
