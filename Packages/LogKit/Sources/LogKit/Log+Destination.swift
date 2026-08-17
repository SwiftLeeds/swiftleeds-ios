extension Log {
    /// Builds a terminal destination, one that writes events out of the process.
    ///
    /// Sensitivity is applied here rather than by the destination, so a destination cannot leak by
    /// forgetting to handle it: `hashed` values arrive as correlation tokens, and `secret` fields
    /// do not arrive at all unless `secrets` says otherwise.
    ///
    /// Use ``init(write:)`` instead for middleware, which needs events untouched.
    ///
    /// - Parameters:
    ///   - salt: Mixed into hashed values so their tokens cannot be reversed by guessing.
    ///   - secrets: Whether the destination is trusted with secret fields. Defaults to removing them.
    ///   - write: Receives each already-classified event.
    public static func destination(
        salt: LogSalt,
        secrets: SecretPolicy = .remove,
        write: @escaping @Sendable (LogEvent) -> Void
    ) -> Log {
        Log { event in
            write(event.classified(salt: salt, secrets: secrets))
        }
    }
}

extension LogEvent {
    /// The event with sensitivity applied to its fields.
    func classified(salt: LogSalt, secrets: SecretPolicy) -> LogEvent {
        LogEvent(
            level: level,
            category: category,
            message: message,
            fields: fields.classified(salt: salt, secrets: secrets),
            source: source
        )
    }
}

extension LogFields {
    /// Replaces each hashed value with its correlation token, and removes secrets unless they are
    /// passed through.
    ///
    /// A field keeps its sensitivity, so a destination can still group by it. Only the value changes.
    func classified(salt: LogSalt, secrets: SecretPolicy) -> LogFields {
        LogFields(
            compactMap { field in
                switch field.sensitivity {
                case .open:
                    field
                case .hashed:
                    .hashed(field.name, String(CorrelationToken(field.value.rendered, salt: salt)))
                case .secret:
                    secrets == .remove ? nil : field
                }
            }
        )
    }
}
