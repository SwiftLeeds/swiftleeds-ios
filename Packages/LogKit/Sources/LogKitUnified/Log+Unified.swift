import LogKit
import os

extension Log {
    /// Writes to Apple's unified logging system.
    ///
    /// Fields are grouped by sensitivity and each group is interpolated once,
    /// because `OSLogMessage` must be a literal at the call site and cannot be
    /// assembled from runtime data. Within a group, fields keep the order they
    /// were written.
    public static func unified(subsystem: LogSubsystem) -> Log {
        // One Logger per category, kept because creating one is not free and
        // categories are few and long-lived.
        let loggers = LoggerCache(subsystem: String(subsystem))

        return Log { event in
            let logger = loggers.logger(for: event.category)

            // Recorded explicitly because OSLogType has no warning: notice and
            // warning would otherwise both read as `default` in Console.
            let level = "[\(event.level.name)]"
            let open = event.fields.filter { $0.sensitivity == .open }.rendered
            let hashed = event.fields.filter { $0.sensitivity == .hashed }.rendered
            let secret = event.fields.filter { $0.sensitivity == .secret }.rendered

            logger.log(
                level: event.level.osLogType,
                """
                \(level, privacy: .public) \
                \(String(event.message), privacy: .public) \
                \(open, privacy: .public) \
                \(hashed, privacy: .private(mask: .hash)) \
                \(secret, privacy: .sensitive)
                """
            )
        }
    }
}

private final class LoggerCache: @unchecked Sendable {
    private let subsystem: String
    private let lock = OSAllocatedUnfairLock(initialState: [LogCategory: Logger]())

    init(subsystem: String) {
        self.subsystem = subsystem
    }

    func logger(for category: LogCategory) -> Logger {
        lock.withLock { cache in
            if let existing = cache[category] { return existing }
            let logger = Logger(subsystem: subsystem, category: String(category))
            cache[category] = logger
            return logger
        }
    }
}
