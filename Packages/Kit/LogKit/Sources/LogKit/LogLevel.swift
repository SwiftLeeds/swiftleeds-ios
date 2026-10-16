/// The severity of a logged event, ordered from least to most severe.
public enum LogLevel: Int, Comparable, Sendable, CaseIterable {
    /// Detail useful only while working on the code.
    case debug
    /// Detail that helps explain a run after the fact.
    case info
    /// Something worth seeing in a default log.
    case notice
    /// Something unexpected that the app carried on through.
    case warning
    /// An operation that failed.
    case error
    /// A failure that leaves the app unable to carry on correctly.
    case critical

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// The level's name, for destinations that record it as text.
    public var name: String {
        switch self {
        case .debug:
            "debug"
        case .info:
            "info"
        case .notice:
            "notice"
        case .warning:
            "warning"
        case .error:
            "error"
        case .critical:
            "critical"
        }
    }
}
