import Foundation

extension HTTPClient {
    package static func urlSession(_ session: URLSession) -> HTTPClient {
        HTTPClient { request in
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            return (data, http)
        }
    }
}
