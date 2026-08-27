import AuthenticationFeature
import Testing

@Suite struct URLPathTests {
    @Test func whenValuesMatch_shouldBeEqual() {
        #expect(URLPath("api/v1/login/ticket") == URLPath("api/v1/login/ticket"))
    }

    @Test func whenValuesDiffer_shouldNotBeEqual() {
        #expect(URLPath("api/v1/login/ticket") != URLPath("api/v1/schedule"))
    }

    @Test func whenWrittenAsStringLiteral_shouldEqualWrappedValue() {
        let path: URLPath = "api/v1/login/ticket"

        #expect(path == URLPath("api/v1/login/ticket"))
    }

    @Test func whenValueIsExtracted_shouldReturnValueGiven() {
        #expect(String(URLPath("api/v1/login/ticket")) == "api/v1/login/ticket")
    }
}
