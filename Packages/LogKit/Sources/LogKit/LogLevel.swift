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
