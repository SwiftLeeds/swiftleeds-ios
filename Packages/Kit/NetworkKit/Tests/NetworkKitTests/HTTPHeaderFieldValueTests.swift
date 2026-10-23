import NetworkKit
import Testing

@Suite struct HTTPHeaderFieldValueTests {
    @Test func whenValueIsWrittenAsStringLiteral_shouldExtractThatString() {
        let value: HTTPHeaderField.Value = "application/json"

        #expect(String(value) == "application/json")
    }

    @Test func whenValuesMatchExactly_shouldBeEqual() {
        let first = HTTPHeaderField.Value("no-cache")
        let second = HTTPHeaderField.Value("no-cache")

        #expect(first == second)
    }

    @Test func whenValuesDifferOnlyByCase_shouldNotBeEqual() {
        #expect(HTTPHeaderField.Value("No-Cache") != HTTPHeaderField.Value("no-cache"))
    }
}
