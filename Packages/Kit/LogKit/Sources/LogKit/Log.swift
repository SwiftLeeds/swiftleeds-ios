/// Somewhere events are written.
///
/// A destination is a `Log`, and so is any composition of destinations, so
/// callers only ever hold one type.
public struct Log: Sendable {
    /// Writes one event to this destination.
    public var write: @Sendable (LogEvent) -> Void

    /// Creates a log.
    public init(write: @escaping @Sendable (LogEvent) -> Void) {
        self.write = write
    }
}
