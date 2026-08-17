extension Log {
    /// A log that writes nowhere.
    ///
    /// Use it to include a destination conditionally without branching, or to
    /// silence logging entirely. Combining with it changes nothing.
    public static let none = Log { _ in }

    /// Writes each event to every given log, in order.
    public static func combine(_ logs: [Log]) -> Log {
        Log { event in
            for log in logs {
                log.write(event)
            }
        }
    }

    /// Writes each event to both logs.
    public func combined(with other: Log) -> Log {
        .combine([self, other])
    }
}
