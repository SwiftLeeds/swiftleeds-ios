import AuthenticationFeature
import Foundation
import Testing

@Suite(.serialized)
struct HTTPClientURLSessionTests {
    private let url: URL

    init() throws {
        url = try #require(URL(string: "https://example.com"))
    }

    @Test func whenServerResponds_shouldReturnDataAndHTTPResponse() async throws {
        let expected = Data("hello".utf8)
        URLProtocolStub.stub(
            data: expected,
            response: try #require(
                HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            ),
            error: nil
        )
        let sut = HTTPClient.urlSession(URLProtocolStub.session())

        let (data, response) = try await sut.send(URLRequest(url: url))

        #expect(data == expected)
        #expect(response.statusCode == 200)
    }

    @Test func whenTransportFails_shouldThrow() async {
        URLProtocolStub.stub(data: nil, response: nil, error: URLError(.notConnectedToInternet))
        let sut = HTTPClient.urlSession(URLProtocolStub.session())

        await #expect(throws: (any Error).self) {
            _ = try await sut.send(URLRequest(url: url))
        }
    }

    @Test func whenResponseIsNotHTTP_shouldThrow() async {
        URLProtocolStub.stub(
            data: Data(),
            response: URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil),
            error: nil
        )
        let sut = HTTPClient.urlSession(URLProtocolStub.session())

        await #expect(throws: (any Error).self) {
            _ = try await sut.send(URLRequest(url: url))
        }
    }
}
