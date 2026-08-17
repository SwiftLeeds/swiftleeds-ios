import Foundation
import LogKit

/// Captures every event written to its `log`, so a test can assert exactly what
/// a composition produced.
final class LogRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [LogEvent] = []

    var events: [LogEvent] {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }

    var log: Log {
        Log { [self] event in
            lock.lock()
            defer { lock.unlock() }
            storage.append(event)
        }
    }
}

extension LogEvent {
    static func stub(
        _ message: MessageTemplate = "event",
        level: LogLevel = .info,
        category: LogCategory = "test"
    ) -> LogEvent {
        LogEvent(level: level, category: category, message: message)
    }
}
