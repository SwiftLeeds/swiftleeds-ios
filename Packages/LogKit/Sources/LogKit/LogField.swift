/// A single named value in a logged event, carrying how sensitive it is.
///
/// A field cannot be built without stating its sensitivity, so an unclassified
/// value is unrepresentable.
public struct LogField: Hashable, Sendable {
    public let name: FieldName
    public let value: LogValue
    public let sensitivity: Sensitivity

    private init(name: FieldName, value: LogValue, sensitivity: Sensitivity) {
        self.name = name
        self.value = value
        self.sensitivity = sensitivity
    }

    /// Builds a field whose sensitivity is only known at runtime, as an interpolation's is.
    package init(_ name: FieldName, _ value: some LogValueRepresentable, _ sensitivity: Sensitivity) {
        self.init(name: name, value: value.logValue, sensitivity: sensitivity)
    }

    /// A value safe to store or transmit anywhere.
    public static func open(_ name: FieldName, _ value: some LogValueRepresentable) -> LogField {
        LogField(name: name, value: value.logValue, sensitivity: .open)
    }

    /// A value that may be correlated but never read.
    public static func hashed(_ name: FieldName, _ value: some LogValueRepresentable) -> LogField {
        LogField(name: name, value: value.logValue, sensitivity: .hashed)
    }

    /// A value that must never leave the device.
    public static func secret(_ name: FieldName, _ value: some LogValueRepresentable) -> LogField {
        LogField(name: name, value: value.logValue, sensitivity: .secret)
    }
}
