import LogKit
import os

extension LogLevel {
    /// The nearest unified-logging type.
    ///
    /// Unified logging has no warning level, so warnings map to `default`
    /// alongside notice; the level is still carried in the event itself.
    var osLogType: OSLogType {
        switch self {
        case .debug:
            .debug
        case .info:
            .info
        case .notice:
            .default
        case .warning:
            .default
        case .error:
            .error
        case .critical:
            .fault
        }
    }
}
