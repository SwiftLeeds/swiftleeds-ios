// TODO: Rename to `TicketReference`

struct TicketCredential: Equatable, Hashable, Sendable {
    private let rawValue: String

    var stringValue: String { rawValue }

    init(_ stringValue: String) {
        self.rawValue = stringValue
    }
}
