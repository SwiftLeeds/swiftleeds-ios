extension Log {
    /// A log that writes nowhere.
    ///
    /// Use it to include a destination conditionally without branching, or to
    /// silence logging entirely. Combining with it changes nothing.
    public static let none = Log { _ in }

    /// Writes each event to every given log, in order.
    ///
    /// - Parameter logs: The destinations, in the order they are written to.
    public static func combine(_ logs: [Log]) -> Log {
        Log { event in
            for log in logs {
                log.write(event)
            }
        }
    }

    /// Writes each event to both logs.
    ///
    /// - Parameter other: The destination written to after this one.
    public func combined(with other: Log) -> Log {
        .combine([self, other])
    }
}
