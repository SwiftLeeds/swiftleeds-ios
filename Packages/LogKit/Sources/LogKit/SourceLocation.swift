/// Where in the source an event was logged.
public struct SourceLocation: Hashable, Sendable {
    /// The file, as `#fileID` gives it: the module name and the file name, not a path.
    public let file: String
    public let function: String
    public let line: Int

    public init(file: String, function: String, line: Int) {
        self.file = file
        self.function = function
        self.line = line
    }

    /// The place this method is called from.
    ///
    /// The literals expand at the call site, so calling it inside a helper records the helper.
    /// Call it where the event happens.
    public static func here(
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) -> SourceLocation {
        SourceLocation(file: file, function: function, line: line)
    }
}
