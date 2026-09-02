import Foundation
import NetworkKit
import Testing

@Suite struct URLSessionPublicContentTests {
    @Test func whenPublicContentSessionIsConfigured_shouldBoundRequestWaitsToThirtySeconds() {
        #expect(URLSession.publicContent.configuration.timeoutIntervalForRequest == 30)
    }

    @Test func whenPublicContentSessionIsConfigured_shouldBoundWholeTransfersToThirtySeconds() {
        #expect(URLSession.publicContent.configuration.timeoutIntervalForResource == 30)
    }

    @Test func whenPublicContentSessionIsConfigured_shouldKeepURLCache() throws {
        let cache = try #require(URLSession.publicContent.configuration.urlCache)

        #expect(cache.memoryCapacity == 10_000_000)
        #expect(cache.diskCapacity == 100_000_000)
    }

    /// A response carrying a session token must never be written to disk, so the authenticated
    /// session stays uncached and only public content uses this one.
    @Test func whenSessionsAreCompared_shouldCacheContentButNotAPI() {
        #expect(URLSession.publicContent.configuration.urlCache != nil)
        #expect(URLSession.api.configuration.urlCache == nil)
    }
}
