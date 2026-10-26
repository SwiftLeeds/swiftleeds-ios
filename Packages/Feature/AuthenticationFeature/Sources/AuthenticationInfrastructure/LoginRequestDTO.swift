import AuthenticationDomain

struct LoginRequestDTO: Encodable {
    /// The JSON keys of the login request.
    enum CodingKeys: String, CodingKey {
        case email = "email"
        case ticket = "ticket"
        case event = "event"
    }

    let email: String
    let ticket: String

    init(_ credential: Credential) {
        email = String(credential.emailAddress)
        ticket = String(credential.ticketReference)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(email, forKey: .email)
        try container.encode(ticket, forKey: .ticket)
        try container.encodeNil(forKey: .event)
    }
}
