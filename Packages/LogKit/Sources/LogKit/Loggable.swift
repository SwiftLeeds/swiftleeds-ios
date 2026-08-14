/// Something that projects itself as an ordered set of fields.
///
/// Conformed to by boundary types built for logging, never by domain models.
public protocol Loggable {
    var logFields: LogFields { get }
}
