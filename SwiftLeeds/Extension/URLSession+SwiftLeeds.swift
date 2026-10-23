import Foundation
import NetworkKit

extension URLSession {
    /// For requests that carry the session bearer. Stores nothing, so no
    /// response holding a token reaches disk.
    static let authenticated = URLSession(configuration: .api())

    /// The bytes of memory the unauthenticated session's cache may use.
    private static let memoryCacheCapacity = 10_000_000

    /// The bytes of disk the unauthenticated session's cache may use.
    private static let diskCacheCapacity = 100_000_000

    /// For requests that carry no credentials. Caches what the server marks
    /// cacheable.
    static let unauthenticated = URLSession(
        configuration: .api(
            cache: URLCache(memoryCapacity: memoryCacheCapacity, diskCapacity: diskCacheCapacity)
        )
    )
}
