extension Log {
    /// Rewrites each event on its way in.
    ///
    /// A log consumes events rather than producing them, so mapping runs
    /// against the input: the transform happens before this log sees anything.
    ///
    /// The transform may change level or category, which cannot be known ahead
    /// of the event, so the result accepts everything and lets `write` decide.
    /// Use ``mappingFields(_:)`` when only fields change.
    public func pullback(_ transform: @escaping @Sendable (LogEvent) -> LogEvent) -> Log {
        Log { event in write(transform(event)) }
    }

    /// Rewrites only the fields, keeping the level and category, so the cheap
    /// pre-check still applies.
    public func mappingFields(_ transform: @escaping @Sendable (LogFields) -> LogFields) -> Log {
        Log(accepts: accepts) { event in
            write(
                LogEvent(
                    level: event.level,
                    category: event.category,
                    message: event.message,
                    fields: transform(event.fields),
                    source: event.source
                )
            )
        }
    }

    /// Passes on only the events satisfying the predicate.
    ///
    /// The predicate needs a whole event, so it cannot inform the pre-check.
    public func filtered(by isIncluded: @escaping @Sendable (LogEvent) -> Bool) -> Log {
        Log(accepts: accepts) { event in
            guard isIncluded(event) else { return }
            write(event)
        }
    }

    /// Drops anything less severe than `level`, before the event is built.
    public func atLeast(_ level: LogLevel) -> Log {
        Log(
            accepts: { eventLevel, category in
                eventLevel >= level && accepts(eventLevel, category)
            },
            write: { event in
                guard event.level >= level else { return }
                write(event)
            }
        )
    }

    /// Passes on only the given categories, before the event is built.
    public func only(_ categories: Set<LogCategory>) -> Log {
        Log(
            accepts: { level, category in
                categories.contains(category) && accepts(level, category)
            },
            write: { event in
                guard categories.contains(event.category) else { return }
                write(event)
            }
        )
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
    public func enriching(with fields: @escaping @Sendable () -> LogFields) -> Log {
        mappingFields { $0.appending(contentsOf: fields()) }
    }

    /// Writes only while consent is given.
    ///
    /// Checked per event, so withdrawing consent takes effect immediately, and
    /// checked in the pre-check too, so a withheld consent costs nothing.
    public func consented(by isGranted: @escaping @Sendable () -> Bool) -> Log {
        Log(
            accepts: { level, category in
                isGranted() && accepts(level, category)
            },
            write: { event in
                guard isGranted() else { return }
                write(event)
            }
        )
    }
}
