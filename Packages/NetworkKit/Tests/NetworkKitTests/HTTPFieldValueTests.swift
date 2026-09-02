import Foundation
import NetworkKit
import Testing

@Suite struct HTTPFieldValueTests {
    @Test func whenValueIsWrittenAsStringLiteral_shouldExtractThatString() {
        let value: HTTPField.Value = "application/json"

        #expect(String(value) == "application/json")
    }

    @Test func whenValuesMatchExactly_shouldBeEqual() {
        #expect(HTTPField.Value("no-cache") == HTTPField.Value("no-cache"))
    }

    @Test func whenValuesDifferOnlyByCase_shouldNotBeEqual() {
        #expect(HTTPField.Value("No-Cache") != HTTPField.Value("no-cache"))
    }
}
