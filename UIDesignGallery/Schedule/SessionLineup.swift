/// Who gives or runs a session, held in the case for its kind.
///
/// A talk or lightning talk has speakers. A workshop or drop-in has hosts.
enum SessionLineup: Equatable, Hashable, Sendable {
    /// A full-length talk, with the speakers who give it.
    case talk(speakers: [SamplePerson])

    /// A short talk, with the speakers who give it.
    case lightningTalk(speakers: [SamplePerson])

    /// A hands-on session, with the hosts who lead it.
    case workshop(hosts: [SamplePerson])

    /// A session people join and leave as they please, with the hosts who run it.
    case dropIn(hosts: [SamplePerson])

    /// The kind of session this lineup belongs to.
    var kind: SessionKind {
        switch self {
        case .talk: .talk
        case .lightningTalk: .lightningTalk
        case .workshop: .workshop
        case .dropIn: .dropIn
        }
    }

    /// Everyone the session credits, speakers or hosts, in the order the screen lists them.
    var credited: [SamplePerson] {
        switch self {
        case .talk(let speakers): speakers
        case .lightningTalk(let speakers): speakers
        case .workshop(let hosts): hosts
        case .dropIn(let hosts): hosts
        }
    }
}
