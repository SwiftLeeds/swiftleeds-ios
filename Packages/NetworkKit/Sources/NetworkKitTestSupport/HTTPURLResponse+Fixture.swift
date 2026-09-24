import Foundation

extension HTTPURLResponse {
    /// Returns a response that carries the given URL and status code.
    ///
    /// - Parameters:
    ///   - url: The URL the response came from. Any absolute URL serves,
    ///     because no request is sent.
    ///   - statusCode: The status code the response carries.
    public static func fixture(
        url: String = "https://example.com",
        statusCode: Int
    ) throws(StubError) -> HTTPURLResponse {
        guard let parsed = URL(string: url) else {
            throw StubError.couldNotParseURL
        }
        guard let response = HTTPURLResponse(
            url: parsed,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        ) else {
            throw StubError.couldNotBuildResponse
        }
        return response
    }
}
