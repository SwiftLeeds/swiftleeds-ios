import LogKit
import os

extension Log {
    /// Writes to Apple's unified logging system.
    ///
    /// Non-secret fields render in one pass and keep their written order; secrets go in a
    /// separate interpolation the system redacts.
    ///
    /// `OSLogMessage` must be a literal at the call site, so the number of interpolations is
    /// fixed and fields cannot be interpolated individually.
    public static func unified(subsystem: LogSubsystem, salt: LogSalt) -> Log {
        let loggers = LoggerCache(subsystem: String(subsystem))

        return Log { event in
            let logger = loggers.logger(for: event.category)

            // OSLogType has no warning, so notice and warning would both read as `default`.
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
