import Foundation

public struct Profile: Equatable, Hashable, Sendable {
    public let name: PersonNameComponents
    public let emailAddress: String
    public let avatarURL: URL
    public let qrCodeURL: URL
    public let ticketReference: String

    public init(
        name: PersonNameComponents,
        emailAddress: String,
        avatarURL: URL,
        qrCodeURL: URL,
        ticketReference: String
    ) {
        self.name = name
        self.emailAddress = emailAddress
        self.avatarURL = avatarURL
        self.qrCodeURL = qrCodeURL
        self.ticketReference = ticketReference
    }
}

extension Profile {
    package init(_ attendee: Attendee) {
        self.init(
            name: attendee.name,
            emailAddress: String(attendee.emailAddress),
            avatarURL: URL(attendee.avatarURL),
            qrCodeURL: URL(attendee.qrCodeURL),
            ticketReference: String(attendee.ticketReference)
        )
    }
}
