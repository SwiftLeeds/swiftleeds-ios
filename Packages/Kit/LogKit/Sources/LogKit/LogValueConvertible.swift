/// A value that knows how it is logged and how sensitive it is.
///
/// Conform a type once and every field built from it is classified the same
/// way. Standard library types deliberately do not conform: a `String` or `URL`
/// has no inherent sensitivity, so those must be classified at the call site.
/// They conform to ``LogValueRepresentable`` alone.
public protocol LogValueConvertible: LogValueRepresentable {
    /// How a destination must treat this value: open, hashed or secret.
    var sensitivity: Sensitivity { get }
}

extension LogField {
    /// Creates a field from a value that classifies itself.
    ///
    /// - Parameters:
    ///   - name: The name the field is logged under.
    ///   - value: The value to log, which supplies its own sensitivity.
    public init(_ name: FieldName, _ value: some LogValueConvertible) {
        switch value.sensitivity {
        case .open:
            self = .open(name, value.logValue)
        case .hashed:
            self = .hashed(name, value.logValue)
        case .secret:
            self = .secret(name, value.logValue)
        }
    }
}
