import Testing

@testable import AuthenticationUI

@Suite struct InitialsTests {
    @Test func whenNameIsEmpty_shouldBeEmpty() {
        #expect(Initials.from("") == "")
    }

    @Test func whenNameIsOnlyWhitespace_shouldBeEmpty() {
        #expect(Initials.from("   \n\t ") == "")
    }

    @Test func whenNameIsSingleWord_shouldBeFirstInitial() {
        #expect(Initials.from("Ada") == "A")
    }

    @Test func whenNameIsFirstAndLast_shouldBeBothInitials() {
        #expect(Initials.from("Ada Lovelace") == "AL")
    }

    @Test func whenNameHasMiddleNames_shouldUseFirstAndLastOnly() {
        #expect(Initials.from("Ada Byron King Lovelace") == "AL")
    }

    @Test func whenNameHasSurroundingWhitespace_shouldIgnoreIt() {
        #expect(Initials.from("  Ada   Lovelace  ") == "AL")
    }

    @Test func whenNameIsLowercase_shouldUppercase() {
        #expect(Initials.from("ada lovelace") == "AL")
    }

    @Test func whenNameIsNonLatin_shouldUseFirstCharacters() {
        #expect(Initials.from("李 明") == "李明")
    }
}
