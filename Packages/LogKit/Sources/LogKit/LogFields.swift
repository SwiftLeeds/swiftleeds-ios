/// An ordered collection of fields.
///
/// Order is a property of the type, not a convention: there is no subscript, no
/// mutation and no way back to the storage, so fields stay in the order the
/// author wrote them. Grouping for display is a destination's concern.
public struct LogFields: Hashable, Sendable, ExpressibleByArrayLiteral {
    private let storage: [LogField]

    public init(_ fields: [LogField] = []) {
        self.storage = fields
    }

    public init(arrayLiteral elements: LogField...) {
        self.init(elements)
    }

    public var isEmpty: Bool { storage.isEmpty }

    public func appending(_ field: LogField) -> LogFields {
        LogFields(storage + [field])
    }

    public func appending(contentsOf other: LogFields) -> LogFields {
        LogFields(storage + other.storage)
    }
}

extension LogFields: Sequence {
    public func makeIterator() -> IndexingIterator<[LogField]> {
        storage.makeIterator()
    }
}
