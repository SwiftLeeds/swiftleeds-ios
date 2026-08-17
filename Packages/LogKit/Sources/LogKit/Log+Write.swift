extension Log {
    /// Records an event.
    ///
    /// The source literals must stay in this signature. Moved into a helper's defaults they
    /// would expand there instead of at the call site.
    public func callAsFunction(
        _ level: LogLevel,
        _ category: LogCategory,
        _ message: LogMessage,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        record(
            level,
            category,
            message,
            SourceLocation(file: file, function: function, line: line)
        )
    }

    /// The shared body behind every entry point.
    ///
    /// Takes the source location as a value rather than defaulting it, so the literals stay at
    /// the call site.
    func record(
        _ level: LogLevel,
        _ category: LogCategory,
        _ message: LogMessage,
        _ source: SourceLocation
    ) {
        write(
            LogEvent(
                level: level,
                category: category,
                message: message.template,
                fields: message.values,
                source: source
            )
        )
    }
}
