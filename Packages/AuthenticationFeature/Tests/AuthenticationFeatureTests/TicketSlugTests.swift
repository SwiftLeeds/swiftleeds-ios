import AuthenticationFeature
import Testing

@Suite struct TicketSlugTests {
    @Test func whenParsingIdentifier_shouldReturnTicketSlug() throws {
        let slug = try TicketSlug("ti_pxqFKr9pPWd6VeYKvMBKpjQ")

        #expect(String(slug) == "ti_pxqFKr9pPWd6VeYKvMBKpjQ")
    }

    @Test func whenParsingIdentifierWithSurroundingWhitespace_shouldTrim() throws {
        let slug = try TicketSlug("  ti_abc123  ")

        #expect(String(slug) == "ti_abc123")
    }

    @Test(arguments: ["", "   ", "\n"])
    func whenParsingEmptyString_shouldThrowEmpty(_ value: String) {
        #expect(throws: TicketSlug.ParsingError.empty) {
            try TicketSlug(value)
        }
    }

    @Test(arguments: ["xyz-9876", "TCKT/0001", "550e8400-e29b-41d4-a716-446655440000"])
    func whenParsingAnotherProvidersIdentifier_shouldReturnTicketSlug(_ value: String) throws {
        let slug = try TicketSlug(value)

        #expect(String(slug) == value)
    }
}
