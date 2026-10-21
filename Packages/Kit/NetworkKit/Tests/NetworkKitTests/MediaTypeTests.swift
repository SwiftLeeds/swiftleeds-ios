import NetworkKit
import Testing

@Suite struct MediaTypeTests {
    @Test func whenValuesMatch_shouldBeEqual() {
        let first = MediaType("application/json")
        let second = MediaType("application/json")

        #expect(first == second)
    }

    @Test func whenValuesDiffer_shouldNotBeEqual() {
        #expect(MediaType("application/json") != MediaType("text/plain"))
    }

    @Test func whenWrittenAsRegistryHierarchy_shouldEqualWrappedValue() {
        let mediaType: MediaType = .application.json

        #expect(mediaType == MediaType("application/json"))
    }

    @Test func whenValueIsExtracted_shouldReturnValueGiven() {
        #expect(String(MediaType("application/vnd.api+json")) == "application/vnd.api+json")
    }
}
