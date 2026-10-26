extension Log {
    /// Rewrites each event on its way in.
    ///
    /// A log consumes events rather than producing them, so the transform runs
    /// before this log sees anything. Use ``Log/mappingFields(_:)`` when only
    /// fields change.
    ///
    /// - Parameter transform: Turns each incoming event into the event this
    ///   log writes.
    /// - Returns: A log that applies the transform to each event before writing it.
    public func pullback(_ transform: @escaping @Sendable (LogEvent) -> LogEvent) -> Log {
        Log { event in write(transform(event)) }
    }

    /// Rewrites only the fields, keeping the level and category.
    ///
    /// - Parameter transform: Turns each event's fields into the fields this
    ///   log writes.
    /// - Returns: A log that applies the transform to each event's fields before writing it.
    public func mappingFields(_ transform: @escaping @Sendable (LogFields) -> LogFields) -> Log {
        pullback { event in
            LogEvent(
                level: event.level,
                category: event.category,
                message: event.message,
                fields: transform(event.fields),
                source: event.source,
            )
        }
    }

    /// Passes on only the events satisfying the predicate.
    ///
    /// - Parameter isIncluded: Returns true for an event this log should
    ///   write.
    /// - Returns: A log that writes an event only when the predicate accepts it.
    public func filtered(by isIncluded: @escaping @Sendable (LogEvent) -> Bool) -> Log {
        Log { event in
            guard isIncluded(event) else { return }
            write(event)
        }
    }

    /// Drops anything less severe than `level`.
    ///
    /// - Parameter level: The least severe level this log still writes.
    /// - Returns: A log that writes only events at `level` or more severe.
    public func atLeast(_ level: LogLevel) -> Log {
        filtered { $0.level >= level }
    }

    /// Passes on only the given categories.
    ///
    /// - Parameter categories: The categories this log still writes.
    /// - Returns: A log that writes only events in the given categories.
    public func only(_ categories: Set<LogCategory>) -> Log {
        filtered { categories.contains($0.category) }
    }

    /// Removes secret fields before this log sees them.
    ///
    /// Put it in front of any destination that leaves the device.
    public func droppingSecrets() -> Log {
        mappingFields { fields in
            LogFields(fields.filter { $0.sensitivity != .secret })
        }
    }

    /// Adds context to every event, after the event's own fields.
    ///
    /// - Parameter fields: Supplies the context fields, read once per event.
    /// - Returns: A log that appends the context fields to each event's own fields.
    public func enriching(with fields: @escaping @Sendable () -> LogFields) -> Log {
        mappingFields { $0.appending(contentsOf: fields()) }
    }

    /// Writes only while consent is given.
    ///
    /// Checked per event, so withdrawing consent takes effect immediately.
    ///
    /// - Parameter isGranted: Returns true while consent stands.
    /// - Returns: A log that writes an event only while `isGranted` returns `true`.
    public func consented(by isGranted: @escaping @Sendable () -> Bool) -> Log {
        filtered { _ in isGranted() }
    }
}
