// One method per level rather than a shared helper: the source literals must
// expand at the call site, so every public entry point has to declare them
// itself. See `callAsFunction`.
extension Log {
    /// Records a debug event.
    public func debug(
        _ message: LogMessage,
        in category: LogCategory,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        record(.debug, category, message, SourceLocation(file: file, function: function, line: line))
    }

    /// Records an informational event.
    public func info(
        _ message: LogMessage,
        in category: LogCategory,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        record(.info, category, message, SourceLocation(file: file, function: function, line: line))
    }

    /// Records an event worth noticing but not acting on.
    public func notice(
        _ message: LogMessage,
        in category: LogCategory,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        record(.notice, category, message, SourceLocation(file: file, function: function, line: line))
    }

    /// Records an event that may lead to a failure.
    public func warning(
        _ message: LogMessage,
        in category: LogCategory,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        record(.warning, category, message, SourceLocation(file: file, function: function, line: line))
    }

    /// Records a failure.
    public func error(
        _ message: LogMessage,
        in category: LogCategory,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        record(.error, category, message, SourceLocation(file: file, function: function, line: line))
    }

    /// Records a failure that leaves the app unable to continue as intended.
    public func critical(
        _ message: LogMessage,
        in category: LogCategory,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        record(.critical, category, message, SourceLocation(file: file, function: function, line: line))
    }
}
