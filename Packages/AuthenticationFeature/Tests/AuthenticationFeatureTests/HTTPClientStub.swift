import AuthenticationFeature
import Foundation

extension HTTPClient {
    static func responding(with data: Data, statusCode: Int) -> HTTPClient {
        HTTPClient { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            return (data, response)
        }
    }

    static func failing(with error: some Error & Sendable) -> HTTPClient {
        HTTPClient { _ in throw error }
    }
}
