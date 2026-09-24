import Foundation
import LogKit

/// A test double that captures every event written to its log.
public final class LogRecorder: @unchecked Sendable {
    /// The lock that guards the captured events, which several tasks may write.
    private let lock = NSLock()

    /// The captured events, in the order they were written.
    private var storage: [LogEvent] = []

    /// Every event captured so far, in the order it was written.
    public var events: [LogEvent] {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }

    /// A log that captures each event it is given.
    public var log: Log {
        Log { [self] event in
            lock.lock()
            defer { lock.unlock() }
            storage.append(event)
        }
    }

    /// Creates a recorder that has captured nothing.
    public init() {}
}
