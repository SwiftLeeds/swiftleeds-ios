import Foundation
import NetworkKit
import Testing

@Suite struct HTTPHeaderFieldValueTests {
    @Test func whenValueIsWrittenAsStringLiteral_shouldExtractThatString() {
        let value: HTTPHeaderField.Value = "application/json"

        #expect(String(value) == "application/json")
    }

    @Test func whenValuesMatchExactly_shouldBeEqual() {
        #expect(HTTPHeaderField.Value("no-cache") == HTTPHeaderField.Value("no-cache"))
    }

    @Test func whenValuesDifferOnlyByCase_shouldNotBeEqual() {
        #expect(HTTPHeaderField.Value("No-Cache") != HTTPHeaderField.Value("no-cache"))
    }
}
