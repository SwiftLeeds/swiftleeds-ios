import AuthenticationFeature
import Foundation
import Testing

@Suite struct TicketReferenceTests {
    @Test func whenParsingValidTicketReference_shouldReturnTicketReference() throws {
        _ = try TicketReference("ABCD-1")
    }

    @Test func whenParsingDoubleDigitTicketReference_shouldReturnTicketReference() throws {
        let sut = try TicketReference("ABCD-12")
        #expect(String(sut) == "ABCD-12")
    }

    @Test(arguments: [("ABCD1", "ABCD-1"), ("ABCD12", "ABCD-12")])
    func whenParsingTicketReferenceWithoutHyphen_shouldNormaliseToHyphenated(
        _ input: String,
        _ expected: String,
    ) throws {
        let sut = try TicketReference(input)
        #expect(String(sut) == expected)
    }

    @Test func whenParsingLowercaseTicketReference_shouldUppercase() throws {
        let sut = try TicketReference("abcd-1")
        #expect(String(sut) == "ABCD-1")
    }

    @Test func whenParsingTicketReferenceWithSurroundingWhitespace_shouldTrim() throws {
        let sut = try TicketReference("  ABCD-1  ")
        #expect(String(sut) == "ABCD-1")
    }

    @Test(arguments: ["ABC-1", "ABCDE-1", "ABCD-123", "ABCD-", "ABCD", ""])
    func whenParsingMalformedTicketReference_shouldThrowInvalidFormat(_ input: String) {
        #expect(throws: TicketReference.ParsingError.invalidFormat) {
            try TicketReference(input)
        }
    }

    @Test func whenDescribed_shouldShowValue() throws {
        let sut = try TicketReference("ABCD-1")
        #expect(String(describing: sut).contains("ABCD-1"))
    }
}
