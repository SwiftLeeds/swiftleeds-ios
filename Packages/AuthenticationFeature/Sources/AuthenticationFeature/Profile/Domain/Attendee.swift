import Foundation

package struct Attendee: Equatable, Hashable, Sendable {
    package let name: PersonNameComponents
    package let emailAddress: EmailAddress
    package let avatarURL: AvatarURL
    package let qrCodeURL: QRCodeURL
    package let ticketReference: TicketReference

    package init(
        name: PersonNameComponents,
        emailAddress: EmailAddress,
        avatarURL: AvatarURL,
        qrCodeURL: QRCodeURL,
        ticketReference: TicketReference
    ) {
        self.name = name
        self.emailAddress = emailAddress
        self.avatarURL = avatarURL
        self.qrCodeURL = qrCodeURL
        self.ticketReference = ticketReference
    }
}
