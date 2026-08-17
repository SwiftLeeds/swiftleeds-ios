import LogKit
import Testing

@Suite struct FieldNameTests {
    @Test func whenWrittenAsStringLiteral_shouldBeAuthored() {
        let sut: FieldName = "pushURL"

        #expect(sut == .authored("pushURL"))
    }

    /// The property the whole sum type exists for: a caller writing the text a gap happens to use
    /// cannot produce that gap's name, so an injected field can never shadow one.
    @Test func whenAuthoredNameMatchesGapPosition_shouldNotBeEqual() {
        let injected: FieldName = "0"

        #expect(injected != .positional(GapIndex(0), label: nil))
    }

    @Test func whenAuthoredNameMatchesGapLabel_shouldNotBeEqual() {
        let injected: FieldName = "email"

        #expect(injected != .positional(GapIndex(0), label: "email"))
    }

    @Test func whenTwoGapsShareLabel_shouldNotBeEqual() {
        let first = FieldName.positional(GapIndex(0), label: "user")
        let second = FieldName.positional(GapIndex(1), label: "user")

        #expect(first != second)
    }

    @Test func whenGapHasLabel_shouldShowLabel() {
        #expect(String(FieldName.positional(GapIndex(3), label: "email")) == "email")
    }

    @Test func whenGapHasNoLabel_shouldShowPosition() {
        #expect(String(FieldName.positional(GapIndex(3), label: nil)) == "3")
    }

    @Test func whenAuthored_shouldShowTheName() {
        #expect(String(FieldName.authored("statusCode")) == "statusCode")
    }
}
