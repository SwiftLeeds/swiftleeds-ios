import Foundation
import NetworkKit
import Testing

@Suite struct URLSessionContentTests {
    @Test func whenContentSessionIsConfigured_shouldBoundRequestWaitsToThirtySeconds() {
        #expect(URLSession.content.configuration.timeoutIntervalForRequest == 30)
    }

    @Test func whenContentSessionIsConfigured_shouldBoundWholeTransfersToThirtySeconds() {
        #expect(URLSession.content.configuration.timeoutIntervalForResource == 30)
    }

    @Test func whenContentSessionIsConfigured_shouldKeepURLCache() throws {
        let cache = try #require(URLSession.content.configuration.urlCache)

        #expect(cache.memoryCapacity == 10_000_000)
        #expect(cache.diskCapacity == 100_000_000)
    }

    /// A response carrying a session token must never be written to disk, so the authenticated
    /// session stays uncached and only public content uses this one.
    @Test func whenSessionsAreCompared_shouldCacheContentButNotAPI() {
        #expect(URLSession.content.configuration.urlCache != nil)
        #expect(URLSession.api.configuration.urlCache == nil)
    }
}
