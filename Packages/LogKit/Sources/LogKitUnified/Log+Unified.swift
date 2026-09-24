import LogKit
import os

extension Log {
    /// Writes to Apple's unified logging system.
    ///
    /// Non-secret fields render in one pass and keep their written order;
    /// secrets go in a separate interpolation the system redacts, which is why
    /// this is one of the few destinations that may hold them.
    ///
    /// `OSLogMessage` must be a literal at the call site, so the number of
    /// interpolations is fixed and fields cannot be interpolated individually.
    ///
    /// - Parameters:
    ///   - subsystem: Names the app the lines came from, in Console.
    ///   - salt: Mixed into hashed values so their tokens cannot be reversed
    ///     by guessing.
    public static func unified(subsystem: LogSubsystem, salt: LogSalt) -> Log {
        let loggers = LoggerCache(subsystem: String(subsystem))

        return .destination(salt: salt, secrets: .passThrough) { event in
            let logger = loggers.logger(for: event.category)

            // OSLogType has no warning, so notice and warning would both read as `default`.
            let level = "[\(event.level.name)]"
            let message = event.message.rendered(with: event.fields)
            let fields = event.fields.renderedWithoutSecrets
            let secrets = event.fields.renderedSecrets

            logger.log(
                level: event.level.osLogType,
                """
                \(level, privacy: .public) \
                \(message, privacy: .public) \
                \(fields, privacy: .public) \
                \(secrets, privacy: .sensitive)
                """
            )
        }
    }
}

/// Holds one `Logger` per category, so each one is built only once.
private final class LoggerCache: @unchecked Sendable {
    /// The subsystem every cached logger is built with.
    private let subsystem: String

    /// The loggers built so far, guarded so any thread may log.
    private let lock = OSAllocatedUnfairLock(initialState: [LogCategory: Logger]())

    /// Creates an empty cache.
    init(subsystem: String) {
        self.subsystem = subsystem
    }

    /// Returns the logger for a category, building it on first use.
    ///
    /// - Parameter category: The area of the app the event came from.
    func logger(for category: LogCategory) -> Logger {
        lock.withLock { cache in
            if let existing = cache[category] { return existing }
            let logger = Logger(subsystem: subsystem, category: String(category))
            cache[category] = logger
            return logger
        }
    }
}
