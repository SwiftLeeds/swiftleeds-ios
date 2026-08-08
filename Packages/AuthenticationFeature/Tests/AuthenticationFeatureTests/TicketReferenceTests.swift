import AuthenticationFeature
import Testing

@Suite struct TicketReferenceTests {
    @Test func whenParsingValidTicketReference_shouldReturnTicketReference() throws {
        _ = try TicketReference("ABCD-1")
    }

    @Test func whenParsingDoubleDigitReference_shouldReturnTicketReference() throws {
        let reference = try TicketReference("ABCD-12")
        #expect(String(reference) == "ABCD-12")
    }

    @Test(arguments: [("ABCD1", "ABCD-1"), ("ABCD12", "ABCD-12")])
    func whenParsingReferenceWithoutHyphen_shouldNormaliseToHyphenated(
        _ input: String,
        _ expected: String
    ) throws {
        let reference = try TicketReference(input)
        #expect(String(reference) == expected)
    }

    @Test func whenParsingLowercaseReference_shouldUppercase() throws {
        let reference = try TicketReference("abcd-1")
        #expect(String(reference) == "ABCD-1")
    }

    @Test func whenParsingReferenceWithSurroundingWhitespace_shouldTrim() throws {
        let reference = try TicketReference("  ABCD-1  ")
        #expect(String(reference) == "ABCD-1")
    }

    @Test(arguments: ["ABC-1", "ABCDE-1", "ABCD-123", "ABCD-", "ABCD", ""])
    func whenParsingMalformedReference_shouldThrowInvalidFormat(_ input: String) {
        #expect(throws: TicketReference.ParsingError.invalidFormat) {
            try TicketReference(input)
        }
    }

    @Test func whenDescribed_shouldRedactValue() throws {
        let reference = try TicketReference("ABCD-1")
        #expect(!String(describing: reference).contains("ABCD-1"))
    }
}
