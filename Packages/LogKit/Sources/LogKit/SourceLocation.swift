/// Where in the source an event was logged.
public struct SourceLocation: Hashable, Sendable {
    public let file: String
    public let function: String
    public let line: Int

    public init(file: String, function: String, line: Int) {
        self.file = file
        self.function = function
        self.line = line
    }

    public static func here(
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) -> SourceLocation {
        SourceLocation(file: file, function: function, line: line)
    }
}
