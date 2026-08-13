extension Log {
    /// Records an event.
    ///
    /// `fields` is only evaluated once something would write the event, so a
    /// log filtered out by level or category costs a single comparison.
    ///
    /// The source literals are defaulted here rather than inside
    /// ``SourceLocation/here(file:function:line:)`` so they expand at the call
    /// site rather than in this file.
    public func callAsFunction(
        _ level: LogLevel,
        _ category: LogCategory,
        _ message: LogMessage,
        fields: @autoclosure @Sendable () -> LogFields = LogFields(),
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        guard accepts(level, category) else { return }

        write(
            LogEvent(
                level: level,
                category: category,
                message: message,
                fields: fields(),
                source: SourceLocation(file: file, function: function, line: line)
            )
        )
    }
}
