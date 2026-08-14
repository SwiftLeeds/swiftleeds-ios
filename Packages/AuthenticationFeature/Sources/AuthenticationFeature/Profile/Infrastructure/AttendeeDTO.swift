import Foundation

struct AttendeeDTO: Decodable {
    let name: String
    let email: String
    let avatarURL: URL
    let qrCodeURL: URL
    let reference: String

    enum CodingKeys: String, CodingKey {
        case name, email, reference
        case avatarURL = "avatar_url"
        case qrCodeURL = "qr_url"
    }
}

extension AttendeeDTO {
    func attendee() throws -> Attendee {
        Attendee(
            name: AttendeeName(name),
            emailAddress: try EmailAddress(email),
            avatarURL: AvatarURL(avatarURL),
            qrCodeURL: QRCodeURL(qrCodeURL),
            ticketReference: try TicketReference(reference)
        )
    }
}
