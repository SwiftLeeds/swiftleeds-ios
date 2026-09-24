/// Identifies the app a log came from, conventionally its bundle identifier.
///
/// Injected rather than defaulted: this project ships as more than one app.
///
/// A subsystem is conventionally written in reverse-DNS form, as
/// `uk.co.swiftleeds.app`. That is a convention, not a rule, and this type does
/// not enforce it, because unified logging accepts any name. The one name it
/// refuses is a blank one, which nobody could read in Console.
public struct LogSubsystem: Hashable, Sendable {
    /// Why a string cannot name a subsystem.
    public enum ParsingError: Error, Equatable, Hashable, Sendable {
        /// The value held no character a person can see.
        case blank
    }

    /// The name.
    private let storage: String

    /// Creates a subsystem, refusing a name that is empty or only whitespace.
    ///
    /// - Parameter value: The name.
    public init(_ value: String) throws(ParsingError) {
        guard value.contains(where: { !$0.isWhitespace }) else { throw .blank }

        storage = value
    }

    /// The name.
    fileprivate var stringValue: String { storage }
}

extension String {
    /// Creates a string holding the subsystem's name.
    ///
    /// - Parameter subsystem: The subsystem to read the name from.
    public init(_ subsystem: LogSubsystem) {
        self = subsystem.stringValue
    }
}
