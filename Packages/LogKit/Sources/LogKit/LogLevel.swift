/// The severity of a logged event, ordered from least to most severe.
public enum LogLevel: Int, Comparable, Sendable, CaseIterable {
    case debug
    case info
    case notice
    case warning
    case error
    case critical

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
