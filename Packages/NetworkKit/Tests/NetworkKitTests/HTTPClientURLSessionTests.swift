import Foundation
import NetworkKit
import Testing

// Everything that touches URLProtocolStub's shared state lives here:
// .serialized only serializes within one suite.
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

    /// The adapter reports what the session reported. It does not wrap or reclassify it, so a
    /// caller can still tell an offline device from a cancelled task.
    @Test func whenTransportFails_shouldThrowSessionErrorUnchanged() async {
        URLProtocolStub.stub(data: nil, response: nil, error: URLError(.notConnectedToInternet))
        let sut = HTTPClient.urlSession(URLProtocolStub.session())

        let thrown = await #expect(throws: URLError.self) {
            _ = try await sut.send(URLRequest(url: url))
        }

        #expect(thrown?.code == .notConnectedToInternet)
    }

    @Test func whenResponseIsNotHTTP_shouldThrowNotHTTP() async {
        URLProtocolStub.stub(
            data: Data(),
            response: URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil),
            error: nil
        )
        let sut = HTTPClient.urlSession(URLProtocolStub.session())

        await #expect(throws: HTTPClient.ResponseError.notHTTP) {
            _ = try await sut.send(URLRequest(url: url))
        }
    }
}
