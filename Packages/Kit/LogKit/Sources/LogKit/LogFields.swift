/// An ordered collection of fields.
///
/// Order is a property of the type, not a convention: there is no subscript, no
/// mutation and no way back to the storage, so fields stay in the order the
/// author wrote them. Grouping for display is a destination's concern.
public struct LogFields: Hashable, Sendable, ExpressibleByArrayLiteral {
    /// The fields, in the order the author wrote them.
    private let storage: [LogField]

    /// Creates a collection holding the given fields, empty by default.
    ///
    /// - Parameter fields: The fields, in the order a destination reads them.
    public init(_ fields: [LogField] = []) {
        self.storage = fields
    }

    public init(arrayLiteral elements: LogField...) {
        self.init(elements)
    }

    /// A Boolean value that is true when there are no fields.
    public var isEmpty: Bool { storage.isEmpty }

    /// Returns these fields with one more added at the end.
    ///
    /// - Parameter field: The field to put after the ones already held.
    public func appending(_ field: LogField) -> LogFields {
        LogFields(storage + [field])
    }

    /// Returns these fields with another collection added at the end.
    ///
    /// - Parameter other: The fields to put after the ones already held.
    public func appending(contentsOf other: LogFields) -> LogFields {
        LogFields(storage + other.storage)
    }
}

extension LogFields: Sequence {
    public func makeIterator() -> IndexingIterator<[LogField]> {
        storage.makeIterator()
    }
}
