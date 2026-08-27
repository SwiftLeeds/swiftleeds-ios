import Foundation

/// A request's content, paired with the media type that describes it.
package struct HTTPBody: Equatable, Hashable, Sendable {
    private let data: Data
    private let mediaType: MediaType

    package static func json(_ data: Data) -> HTTPBody {
        HTTPBody(data: data, mediaType: .application.json)
    }

    /// Writes the content and its Content-Type header onto the request.
    package func attach(to request: inout URLRequest) {
        request.httpBody = data
        request.setValue(String(mediaType), forHTTPHeaderField: "Content-Type")
    }
}
