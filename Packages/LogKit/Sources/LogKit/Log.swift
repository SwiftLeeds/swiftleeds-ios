/// Somewhere events are written.
///
/// A destination is a `Log`, and so is any composition of destinations, so
/// callers only ever hold one type.
public struct Log: Sendable {
    /// Whether an event with this level and category would reach anything.
    ///
    /// Consulted before an event is built, so a log nobody keeps costs only
    /// this comparison. Answering `true` is always safe: `write` filters again.
    public var accepts: @Sendable (LogLevel, LogCategory) -> Bool

    public var write: @Sendable (LogEvent) -> Void

    public init(
        accepts: @escaping @Sendable (LogLevel, LogCategory) -> Bool,
        write: @escaping @Sendable (LogEvent) -> Void
    ) {
        self.accepts = accepts
        self.write = write
    }

    /// A destination that accepts everything.
    public init(write: @escaping @Sendable (LogEvent) -> Void) {
        self.init(accepts: { _, _ in true }, write: write)
    }
}
