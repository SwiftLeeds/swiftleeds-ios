struct LoginRequestDTO: Encodable {
    let email: String
    let ticket: String

    enum CodingKeys: String, CodingKey {
        case email, ticket, event
    }

    init(_ credential: Credential) {
        email = String(credential.email)
        ticket = String(credential.ticketReference)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(email, forKey: .email)
        try container.encode(ticket, forKey: .ticket)
        try container.encodeNil(forKey: .event)
    }
}
