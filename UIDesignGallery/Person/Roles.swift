/// The standings a person holds, in the order their badges show.
///
/// A person always holds at least one, so the first is stored apart from the
/// rest.
struct Roles: Equatable, Hashable, Sendable {
    /// The standing shown first.
    let first: TicketRole

    /// The standings shown after the first, if any.
    let others: [TicketRole]

    /// Every standing, in the order the badges show.
    var all: [TicketRole] { [first] + others }

    /// Creates the standings a person holds.
    ///
    /// - Parameters:
    ///   - first: The standing shown first.
    ///   - others: The standings shown after the first, if any.
    init(_ first: TicketRole, _ others: TicketRole...) {
        self.first = first
        self.others = others
    }
}
