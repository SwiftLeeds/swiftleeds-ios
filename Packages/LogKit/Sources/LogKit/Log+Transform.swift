extension Log {
    /// Rewrites each event on its way in.
    ///
    /// A log consumes events rather than producing them, so mapping runs
    /// against the input: the transform happens before this log sees anything.
    public func pullback(_ transform: @escaping @Sendable (LogEvent) -> LogEvent) -> Log {
        Log { event in write(transform(event)) }
    }

    /// Passes on only the events satisfying the predicate.
    public func filtered(by isIncluded: @escaping @Sendable (LogEvent) -> Bool) -> Log {
        Log { event in
            guard isIncluded(event) else { return }
            write(event)
        }
    }

    /// Drops anything less severe than `level`.
    public func atLeast(_ level: LogLevel) -> Log {
        filtered { $0.level >= level }
    }

    /// Passes on only the given categories.
    public func only(_ categories: Set<LogCategory>) -> Log {
        filtered { categories.contains($0.category) }
    }

    /// Removes secret fields before this log sees them.
    ///
    /// Put it in front of any destination that leaves the device.
    public func droppingSecrets() -> Log {
        pullback { event in
            LogEvent(
                level: event.level,
                category: event.category,
                message: event.message,
                fields: LogFields(event.fields.filter { $0.sensitivity != .secret }),
                source: event.source
            )
        }
    }

    /// Adds context to every event, after the event's own fields.
    public func enriching(with fields: @escaping @Sendable () -> LogFields) -> Log {
        pullback { event in
            LogEvent(
                level: event.level,
                category: event.category,
                message: event.message,
                fields: event.fields.appending(contentsOf: fields()),
                source: event.source
            )
        }
    }

    /// Writes only while consent is given.
    ///
    /// Checked per event, so withdrawing consent takes effect immediately.
    public func consented(by isGranted: @escaping @Sendable () -> Bool) -> Log {
        filtered { _ in isGranted() }
    }
}
