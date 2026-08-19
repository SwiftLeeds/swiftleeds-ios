import Foundation

package struct AttendeeDTO: Decodable {
    /// The field is carried as data rather than a case per field, so adding one to `Attendee` needs
    /// no change here.
    package struct FieldError: Error {
        let field: Ticket.CodingKeys
        let reason: any Error
    }

    let ticket: Ticket

    struct Ticket: Decodable {
        let firstName: String
        let lastName: String
        let email: String
        let avatarURL: URL
        let reference: String
        let slug: String

        enum CodingKeys: String, CodingKey {
            case firstName = "first_name"
            case lastName = "last_name"
            case email
            case reference
            case slug
            case avatarURL = "avatar_url"
        }
    }
}

extension AttendeeDTO {
    func attendee() throws(FieldError) -> Attendee {
        Attendee(
            name: PersonNameComponents(givenName: ticket.firstName, familyName: ticket.lastName),
            emailAddress: try parsed(.email) { try EmailAddress(ticket.email) },
            avatarURL: AvatarURL(ticket.avatarURL),
            ticketReference: try parsed(.reference) { try TicketReference(ticket.reference) },
            ticketSlug: try parsed(.slug) { try TicketSlug(ticket.slug) }
        )
    }

    private func parsed<Value>(
        _ field: Ticket.CodingKeys,
        _ parse: () throws -> Value
    ) throws(FieldError) -> Value {
        do {
            return try parse()
        } catch {
            throw FieldError(field: field, reason: error)
        }
    }
}
