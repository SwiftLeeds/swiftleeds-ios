import Foundation
import NetworkKit

extension HTTPClient {
    /// Returns a client that answers each request with the same body and code.
    ///
    /// A request with no URL, or a URL and status code that `HTTPURLResponse` refuses, throws
    /// ``StubError/couldNotBuildResponse``.
    ///
    /// ```swift
    /// let client = HTTPClient.responding(with: Data(), statusCode: 200)
    /// ```
    ///
    /// - Parameters:
    ///   - data: The body to return.
    ///   - statusCode: The status code to return.
    /// - Returns: A client that answers each request with the given body and status code.
    public static func responding(with data: Data, statusCode: HTTPStatusCode) -> HTTPClient {
        HTTPClient { request in
            guard let url = request.url,
                let response = HTTPURLResponse(
                    url: url,
                    statusCode: Int(statusCode),
                    httpVersion: nil,
                    headerFields: nil,
                )
            else { throw StubError.couldNotBuildResponse }
            return (data, response)
        }
    }

    /// Returns a client that throws the same error for every request.
    ///
    /// ```swift
    /// let client = HTTPClient.failing(with: URLError(.notConnectedToInternet))
    /// ```
    ///
    /// - Parameter error: The error to throw.
    /// - Returns: A client whose every request throws the given error.
    public static func failing(with error: some Error & Sendable) -> HTTPClient {
        HTTPClient { _ in throw error }
    }
}
