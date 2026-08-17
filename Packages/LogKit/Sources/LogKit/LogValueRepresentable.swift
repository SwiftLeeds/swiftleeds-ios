/// A value that can be written into a log.
///
/// Sensitivity is deliberately not part of this protocol. A `String` or `Int`
/// has no inherent sensitivity, so the call site states it by choosing
/// ``LogField/open(_:_:)``, ``LogField/hashed(_:_:)`` or
/// ``LogField/secret(_:_:)``. A type that does carry its own sensitivity
/// conforms to ``LogValueConvertible`` instead.
public protocol LogValueRepresentable {
    var logValue: LogValue { get }
}

extension LogValue: LogValueRepresentable {
    public var logValue: LogValue { self }
}

extension String: LogValueRepresentable {
    public var logValue: LogValue { .string(self) }
}

extension Int: LogValueRepresentable {
    public var logValue: LogValue { .integer(self) }
}

extension Double: LogValueRepresentable {
    public var logValue: LogValue { .double(self) }
}

extension Bool: LogValueRepresentable {
    public var logValue: LogValue { .boolean(self) }
}
