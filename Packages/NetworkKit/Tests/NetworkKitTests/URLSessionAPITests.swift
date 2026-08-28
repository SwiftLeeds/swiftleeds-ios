import Foundation
import NetworkKit
import Testing

@Suite struct URLSessionAPITests {
    @Test func whenAPISessionIsConfigured_shouldBoundRequestWaitsToThirtySeconds() {
        #expect(URLSession.api.configuration.timeoutIntervalForRequest == 30)
    }

    @Test func whenAPISessionIsConfigured_shouldBoundWholeTransfersToThirtySeconds() {
        #expect(URLSession.api.configuration.timeoutIntervalForResource == 30)
    }

    @Test func whenAPISessionIsConfigured_shouldKeepNoURLCache() {
        #expect(URLSession.api.configuration.urlCache == nil)
    }

    @Test func whenAPISessionIsConfigured_shouldFailFastWithoutConnectivity() {
        #expect(URLSession.api.configuration.waitsForConnectivity == false)
    }
}
