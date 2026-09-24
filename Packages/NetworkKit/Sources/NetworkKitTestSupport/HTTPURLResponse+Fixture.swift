import Foundation
import NetworkKit

extension HTTPURLResponse {
    /// Returns a response that carries the given URL and status code.
    ///
    /// - Parameters:
    ///   - url: The URL the response came from. Text that is not a URL throws
    ///     ``StubError/couldNotParseURL``.
    ///   - statusCode: The status code the response carries.
    public static func fixture(
        url: String = "https://example.com",
        statusCode: HTTPStatusCode
    ) throws(StubError) -> HTTPURLResponse {
        guard let parsed = URL(string: url) else {
            throw StubError.couldNotParseURL
        }
        guard let response = HTTPURLResponse(
            url: parsed,
            statusCode: Int(statusCode),
            httpVersion: nil,
            headerFields: nil
        ) else {
            throw StubError.couldNotBuildResponse
        }
        return response
    }
}
