import Foundation
import NetworkKit

extension HTTPClient {
    /// Returns a client that answers each request with the same body and code.
    ///
    /// A request carrying no URL throws ``StubError/couldNotBuildResponse``.
    ///
    /// - Parameters:
    ///   - data: The body to return.
    ///   - statusCode: The status code to return.
    public static func responding(with data: Data, statusCode: HTTPStatusCode) -> HTTPClient {
        HTTPClient { request in
            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: Int(statusCode),
                      httpVersion: nil,
                      headerFields: nil
                  )
            else { throw StubError.couldNotBuildResponse }
            return (data, response)
        }
    }

    /// Returns a client that throws the same error for every request.
    ///
    /// - Parameter error: The error to throw.
    public static func failing(with error: some Error & Sendable) -> HTTPClient {
        HTTPClient { _ in throw error }
    }
}
