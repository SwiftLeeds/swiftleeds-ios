package struct Attendee: Equatable, Hashable, Sendable {
    package let name: AttendeeName
    package let emailAddress: EmailAddress
    package let avatarURL: AvatarURL
    package let qrCodeURL: QRCodeURL
    package let ticketReference: TicketReference

    package init(
        name: AttendeeName,
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
