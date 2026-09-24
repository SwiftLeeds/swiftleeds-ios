/// Identifies the app a log came from, conventionally its bundle identifier.
///
/// Injected rather than defaulted: this project ships as more than one app.
///
/// A subsystem is conventionally written in reverse-DNS form, as `uk.co.swiftleeds.app`. That is a
/// convention, not a rule, and this type does not enforce it. Apple's unified logging accepts any
/// name, so refusing one would reject a subsystem the platform allows.
public struct LogSubsystem: Hashable, Sendable {
    /// Why a string cannot name a subsystem.
    public enum ParsingError: Error, Equatable, Hashable, Sendable {
        /// The value held no characters.
        case empty

        /// The value held a space, a tab or a newline.
        case containsWhitespace
    }

    /// The name.
    private let storage: String

    /// Creates a subsystem.
    ///
    /// - Parameter value: The name, which must hold at least one character and no whitespace.
    public init(_ value: String) throws(ParsingError) {
        guard !value.isEmpty else { throw .empty }
        guard !value.contains(where: \.isWhitespace) else { throw .containsWhitespace }

        storage = value
    }

    /// The name.
    fileprivate var stringValue: String { storage }
}

extension String {
    /// Creates the subsystem's name.
    ///
    /// - Parameter subsystem: The subsystem to name.
    public init(_ subsystem: LogSubsystem) {
        self = subsystem.stringValue
    }
}
