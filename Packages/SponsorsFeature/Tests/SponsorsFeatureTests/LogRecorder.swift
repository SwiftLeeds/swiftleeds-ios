import Foundation
import LogKit

/// Captures every event written to its `log`, so a test can assert what was recorded.
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
