#warning("Is this used?")
#warning("Should we have DTOs for `EmailAddress` and `TicketReference`?")
struct AuthRequestDTO: Encodable {
    let email: String
    let ticket_reference: String
}
