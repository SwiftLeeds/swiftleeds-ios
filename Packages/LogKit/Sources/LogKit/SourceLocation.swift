/// Where in the source an event was logged.
public struct SourceLocation: Hashable, Sendable {
    /// The file, expected in `#fileID` form: the module name and the file
    /// name, not a path.
    public let file: String

    /// The function, expected in `#function` form: its name and argument
    /// labels, without types.
    public let function: String

    /// The line number within the file, counted from one.
    public let line: Int

    /// Creates a location.
    public init(file: String, function: String, line: Int) {
        self.file = file
        self.function = function
        self.line = line
    }

    /// Returns the place this method is called from.
    ///
    /// The literals expand at the call site, so calling it inside a helper
    /// records the helper. Call it where the event happens.
    ///
    /// - Parameters:
    ///   - file: The file, left to expand from `#fileID`.
    ///   - function: The function, left to expand from `#function`.
    ///   - line: The line, left to expand from `#line`.
    public static func here(
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) -> SourceLocation {
        SourceLocation(file: file, function: function, line: line)
    }
}
