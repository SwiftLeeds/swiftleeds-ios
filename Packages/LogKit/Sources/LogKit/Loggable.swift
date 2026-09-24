/// Something that projects itself as an ordered set of fields.
///
/// Conformed to by boundary types built for logging, never by domain models.
public protocol Loggable {
    /// The fields this value contributes to a log line, in order.
    var logFields: LogFields { get }
}
