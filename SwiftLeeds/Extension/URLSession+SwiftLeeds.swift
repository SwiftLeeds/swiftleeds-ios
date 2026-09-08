import Foundation
import NetworkKit

extension URLSession {
    /// For requests that carry the session bearer. Stores nothing, so no
    /// response holding a token reaches disk.
    static let authenticated = URLSession(configuration: .api())

    /// For requests that carry no credentials. Caches what the server marks
    /// cacheable.
    static let unauthenticated = URLSession(
        configuration: .api(cache: URLCache(memoryCapacity: 10_000_000, diskCapacity: 100_000_000))
    )
}
