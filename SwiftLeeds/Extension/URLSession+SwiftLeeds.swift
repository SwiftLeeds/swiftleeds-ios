import Foundation
import NetworkKit

extension URLSession {
    /// A URL session for requests that carry the sign-in bearer token.
    ///
    /// It stores nothing, so no response holding a token reaches disk.
    static let authenticated = URLSession(configuration: .api())

    /// The bytes of memory the unauthenticated session's cache may use.
    private static let memoryCacheCapacity = 10_000_000

    /// The bytes of disk the unauthenticated session's cache may use.
    private static let diskCacheCapacity = 100_000_000

    /// A URL session for requests that carry no credentials.
    ///
    /// It caches what the server marks cacheable.
    static let unauthenticated = URLSession(
        configuration: .api(
            cache: URLCache(memoryCapacity: memoryCacheCapacity, diskCapacity: diskCacheCapacity)
        )
    )
}
