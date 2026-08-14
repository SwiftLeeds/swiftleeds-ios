import Foundation

struct AttendeeDTO: Decodable {
    let ticket: Ticket

    struct Ticket: Decodable {
        let firstName: String
        let lastName: String
        let email: String
        let avatarURL: URL
        let qrCodeURL: URL
        let reference: String

        enum CodingKeys: String, CodingKey {
            case firstName = "first_name"
            case lastName = "last_name"
            case email, reference
            case avatarURL = "avatar_url"
            case qrCodeURL = "qr_url"
        }
    }
}

extension AttendeeDTO {
    func attendee() throws -> Attendee {
        Attendee(
            name: PersonNameComponents(givenName: ticket.firstName, familyName: ticket.lastName),
            emailAddress: try EmailAddress(ticket.email),
            avatarURL: AvatarURL(ticket.avatarURL),
            qrCodeURL: QRCodeURL(ticket.qrCodeURL),
            ticketReference: try TicketReference(ticket.reference)
        )
    }
}
