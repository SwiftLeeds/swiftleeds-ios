/// A single named value in a logged event, carrying how sensitive it is.
///
/// A field cannot be built without stating its sensitivity, so an unclassified
/// value is unrepresentable.
public struct LogField: Hashable, Sendable {
    /// The name the field is logged under.
    public let name: FieldName

    /// The field's contents, kept typed for a structured destination.
    public let value: LogValue

    /// How a destination must treat the value: open, hashed or secret.
    public let sensitivity: Sensitivity

    /// Creates a field.
    private init(name: FieldName, value: LogValue, sensitivity: Sensitivity) {
        self.name = name
        self.value = value
        self.sensitivity = sensitivity
    }

    /// Builds a field whose sensitivity is only known at runtime, as an
    /// interpolation's is.
    ///
    /// - Parameters:
    ///   - name: The name the field is logged under.
    ///   - value: The value to log.
    ///   - sensitivity: How a destination must treat the value.
    package init(_ name: FieldName, _ value: some LogValueRepresentable, _ sensitivity: Sensitivity) {
        self.init(name: name, value: value.logValue, sensitivity: sensitivity)
    }

    /// Builds a field whose value is safe to store or transmit anywhere.
    ///
    /// - Parameters:
    ///   - name: The name the field is logged under.
    ///   - value: The value to log.
    public static func open(_ name: FieldName, _ value: some LogValueRepresentable) -> LogField {
        LogField(name: name, value: value.logValue, sensitivity: .open)
    }

    /// Builds a field whose value may be correlated but never read.
    ///
    /// - Parameters:
    ///   - name: The name the field is logged under.
    ///   - value: The value to log.
    public static func hashed(_ name: FieldName, _ value: some LogValueRepresentable) -> LogField {
        LogField(name: name, value: value.logValue, sensitivity: .hashed)
    }

    /// Builds a field whose value must never leave the device.
    ///
    /// - Parameters:
    ///   - name: The name the field is logged under.
    ///   - value: The value to log.
    public static func secret(_ name: FieldName, _ value: some LogValueRepresentable) -> LogField {
        LogField(name: name, value: value.logValue, sensitivity: .secret)
    }
}
