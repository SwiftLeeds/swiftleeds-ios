import NetworkKit
import Testing

@Suite struct HTTPStatusCodeTests {
    @Test func whenValuesMatch_shouldBeEqual() {
        let first = HTTPStatusCode(404)
        let second = HTTPStatusCode(404)

        #expect(first == second)
    }

    @Test func whenValuesDiffer_shouldNotBeEqual() {
        #expect(HTTPStatusCode(200) != HTTPStatusCode(201))
    }

    @Test func whenWrittenAsIntegerLiteral_shouldEqualParsedValue() {
        let code: HTTPStatusCode = 503

        #expect(code == HTTPStatusCode(503))
    }

    @Test func whenValueIsExtracted_shouldReturnValueGiven() {
        #expect(Int(HTTPStatusCode(418)) == 418)
    }

    @Test func whenCodesAreOrdered_shouldCompareByValue() {
        #expect(HTTPStatusCode(200) < HTTPStatusCode(300))
    }

    @Test func whenCodeFallsInRange_shouldMatchRangePattern() {
        let redirection: ClosedRange<HTTPStatusCode> = 300...399

        #expect(redirection.contains(302))
    }

    @Test func whenCodeFallsOutsideRange_shouldNotMatchRangePattern() {
        let redirection: ClosedRange<HTTPStatusCode> = 300...399

        #expect(!redirection.contains(299))
        #expect(!redirection.contains(400))
    }
}
