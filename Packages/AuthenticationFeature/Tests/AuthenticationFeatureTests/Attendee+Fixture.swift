import AuthenticationFeature
import Foundation
import Testing

extension Attendee {
    /// Any well-formed attendee. `FetchProfileTests` pins these values in its own expectation, so
    /// changing one changes that test.
    static var fixture: Attendee {
        get throws {
            Attendee(
                name: PersonNameComponents(givenName: "Ada", familyName: "Lovelace"),
                emailAddress: try EmailAddress("ada@example.com"),
                avatarURL: AvatarURL(try #require(URL(string: "https://example.com/avatar.png"))),
                ticketReference: try TicketReference("ABCD-12"),
                ticketSlug: try TicketSlug("ti_abc")
            )
        }
    }
}
