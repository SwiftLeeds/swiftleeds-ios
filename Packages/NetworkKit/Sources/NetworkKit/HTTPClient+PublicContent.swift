import Foundation

extension HTTPClient {
    /// The transport for public content, which caches what the server marks
    /// cacheable.
    ///
    /// Nothing carrying credentials may use this client, because a cached
    /// response is written to disk.
    public static let publicContent = HTTPClient.urlSession(.publicContent)
}
