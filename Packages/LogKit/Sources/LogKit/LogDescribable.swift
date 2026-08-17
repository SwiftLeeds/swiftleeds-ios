/// A type that knows how it should read in a log.
///
/// Conform anything whose default rendering is unhelpful — notably framework errors, which reflect
/// into a dump rather than describing themselves. Sensitivity is not part of this protocol: an
/// error's text is like a `String`, so the call site classifies it.
public protocol LogDescribable {
    /// How this value should read in a log.
    var logDescription: String { get }
}

extension String {
    /// Creates the error's own log description, or its default rendering if it has none.
    ///
    /// - Parameter error: The error to describe.
    public init(logDescribing error: any Error) {
        self = (error as? LogDescribable)?.logDescription ?? "\(error)"
    }
}

extension LogField {
    /// A field carrying an error, safe to store or transmit anywhere.
    ///
    /// - Parameters:
    ///   - name: The field's name.
    ///   - error: The error to describe.
    public static func open(_ name: FieldName, _ error: any Error) -> LogField {
        .open(name, String(logDescribing: error))
    }

    /// A field carrying an error that may be correlated but never read.
    ///
    /// - Parameters:
    ///   - name: The field's name.
    ///   - error: The error to describe.
    public static func hashed(_ name: FieldName, _ error: any Error) -> LogField {
        .hashed(name, String(logDescribing: error))
    }

    /// A field carrying an error that must never leave the device.
    ///
    /// - Parameters:
    ///   - name: The field's name.
    ///   - error: The error to describe.
    public static func secret(_ name: FieldName, _ error: any Error) -> LogField {
        .secret(name, String(logDescribing: error))
    }
}
