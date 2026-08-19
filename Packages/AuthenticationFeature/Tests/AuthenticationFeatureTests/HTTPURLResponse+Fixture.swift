import Foundation
import Testing

extension HTTPURLResponse {
    static func fixture(url: String, statusCode: Int) throws -> HTTPURLResponse {
        let parsed = try #require(URL(string: url))
        return try #require(
            HTTPURLResponse(url: parsed, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        )
    }
}
