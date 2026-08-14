import LogKit
import os

extension Log {
    /// Writes to Apple's unified logging system.
    ///
    /// Hashed values are replaced with a salted token computed per field, so
    /// one value keeps the same token when its neighbours change. Because the
    /// tokens are already non-reversible, every non-secret field is rendered in
    /// one pass and keeps the order it was written. Secrets go in a separate
    /// interpolation the system redacts.
    ///
    /// `OSLogMessage` must be a literal at the call site, so the number of
    /// interpolations is fixed and fields cannot be interpolated individually.
    public static func unified(subsystem: LogSubsystem, salt: LogSalt) -> Log {
        // One Logger per category, kept because creating one is not free and
        // categories are few and long-lived.
        let loggers = LoggerCache(subsystem: String(subsystem))

        return Log { event in
            let logger = loggers.logger(for: event.category)

            // Written out because OSLogType has no warning: notice and warning
            // would otherwise both read as `default` in Console.
            let level = "[\(event.level.name)]"
            let fields = event.fields.rendered(salt: salt)
            let secrets = event.fields.renderedSecrets

            logger.log(
                level: event.level.osLogType,
                """
                \(level, privacy: .public) \
                \(String(event.message), privacy: .public) \
                \(fields, privacy: .public) \
                \(secrets, privacy: .sensitive)
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
