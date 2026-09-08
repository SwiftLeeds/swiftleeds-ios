import Foundation
import NetworkKit
import Testing

@Suite struct URLSessionConfigurationAPITests {
    @Test func whenConfigurationIsMade_shouldBoundRequestWaitsToThirtySeconds() {
        #expect(URLSessionConfiguration.api().timeoutIntervalForRequest == 30)
    }

    @Test func whenConfigurationIsMade_shouldBoundWholeTransfersToThirtySeconds() {
        #expect(URLSessionConfiguration.api().timeoutIntervalForResource == 30)
    }

    @Test func whenTimeoutIsGiven_shouldBoundBothWaitsToIt() {
        let configuration = URLSessionConfiguration.api(timeout: 5)

        #expect(configuration.timeoutIntervalForRequest == 5)
        #expect(configuration.timeoutIntervalForResource == 5)
    }

    @Test func whenNoCacheIsGiven_shouldStoreNothing() {
        #expect(URLSessionConfiguration.api().urlCache == nil)
    }

    @Test func whenCacheIsGiven_shouldStoreInThatCache() {
        let cache = URLCache(memoryCapacity: 1_000, diskCapacity: 2_000)

        #expect(URLSessionConfiguration.api(cache: cache).urlCache === cache)
    }

    @Test func whenConfigurationIsMade_shouldFailFastWithoutConnectivity() {
        #expect(URLSessionConfiguration.api().waitsForConnectivity == false)
    }
}
