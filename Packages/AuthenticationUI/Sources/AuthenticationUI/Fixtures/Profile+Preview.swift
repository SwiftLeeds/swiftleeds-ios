import AuthenticationFeature
import Foundation

#if DEBUG
package extension Profile {
    static var preview: Profile {
        Profile(
            name: PersonNameComponents(givenName: "Ada", familyName: "Lovelace"),
            emailAddress: "ada@example.com",
            avatarURL: URL(string: "https://example.com/avatar.png")!,
            qrCodeURL: URL(string: "https://example.com/qr.png")!,
            ticketReference: "ABCD-1",
            ticketSlug: try! TicketSlug("ti_pxqFKr9pPWd6VeYKvMBKpjQ")
        )
    }
}
#endif
