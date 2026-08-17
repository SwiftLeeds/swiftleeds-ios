/// Somewhere events are written.
///
/// A destination is a `Log`, and so is any composition of destinations, so
/// callers only ever hold one type.
public struct Log: Sendable {
    public var write: @Sendable (LogEvent) -> Void

    public init(write: @escaping @Sendable (LogEvent) -> Void) {
        self.write = write
    }
}
