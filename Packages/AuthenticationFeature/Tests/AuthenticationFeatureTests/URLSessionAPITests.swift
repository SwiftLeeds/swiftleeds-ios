import AuthenticationFeature
import Foundation
import Testing

@Suite struct URLSessionAPITests {
    @Test func whenSessionIsConfigured_shouldBoundRequestWaitsToThirtySeconds() {
        #expect(URLSession.api.configuration.timeoutIntervalForRequest == 30)
    }

    @Test func whenSessionIsConfigured_shouldBoundWholeTransfersToThirtySeconds() {
        #expect(URLSession.api.configuration.timeoutIntervalForResource == 30)
    }

    @Test func whenSessionIsConfigured_shouldKeepNoURLCache() {
        #expect(URLSession.api.configuration.urlCache == nil)
    }

    @Test func whenSessionIsConfigured_shouldFailFastWithoutConnectivity() {
        #expect(URLSession.api.configuration.waitsForConnectivity == false)
    }
}
