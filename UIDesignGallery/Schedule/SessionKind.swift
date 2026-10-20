/// The kind of a session, which sets its name.
enum SessionKind: Equatable, Hashable, Sendable {
    /// A full-length talk.
    case talk

    /// A short talk.
    case lightningTalk

    /// A hands-on session where people work along.
    case workshop

    /// A session that people join and leave as they please.
    case dropIn

    /// What people call the kind.
    var displayName: String {
        switch self {
        case .talk: "Talk"
        case .lightningTalk: "Lightning talk"
        case .workshop: "Workshop"
        case .dropIn: "Drop-in"
        }
    }
}
