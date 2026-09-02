import Foundation
import NetworkKit
import Testing

@Suite struct HTTPContentTests {
    @Test func whenJSONContentIsAttached_shouldCarryBytesGiven() throws {
        let bytes = Data(#"{"ticket": "ABCD-12"}"#.utf8)
        var request = try urlRequest()

        HTTPContent.json(bytes).attach(to: &request)

        #expect(request.httpBody == bytes)
    }

    @Test func whenJSONContentIsAttached_shouldDeclareJSONContentType() throws {
        var request = try urlRequest()

        HTTPContent.json(Data()).attach(to: &request)

        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    private func urlRequest() throws -> URLRequest {
        URLRequest(url: try #require(URL(string: "https://example.com")))
    }
}
