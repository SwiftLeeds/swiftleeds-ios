public struct SessionToken: Equatable, Hashable, Sendable {
    package var stringValue: String { rawValue }

    private let rawValue: String

    fileprivate init(unchecked stringValue: String) {
        self.rawValue = stringValue
    }

    package init(_ stringValue: String, strategy: ParseStrategy) throws {
        self = try strategy.parse(stringValue)
    }
}

extension SessionToken {
    public enum ParseError: Error, Sendable {
        case malformed
    }

    public struct ParseStrategy: Sendable {
        private let isValid: @Sendable (String) -> Bool

        package init(_ isValid: @escaping @Sendable (String) -> Bool) {
            self.isValid = isValid
        }

        public func parse(_ stringValue: String) throws(ParseError)-> SessionToken {
            guard isValid(stringValue) else { throw .malformed }
            return SessionToken(unchecked: stringValue)
        }
    }
}

//public enum SessionTokenFormatError: Error, Sendable {
//    case malformed
//}
//
//public struct SessionTokenFormat: Sendable {
//    private let isValid: @Sendable (String) -> Bool
//
//    package init(_ isValid: @escaping @Sendable (String) -> Bool) {
//        self.isValid = isValid
//    }
//
//    public func parse(_ stringValue: String) throws(SessionTokenFormatError)-> SessionToken {
//        guard isValid(stringValue) else { throw .malformed }
//        return SessionToken(unchecked: stringValue)
//    }
//}
