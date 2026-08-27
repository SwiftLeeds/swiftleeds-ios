import AuthenticationFeature
import Foundation
import Testing

@Suite struct HTTPBodyTests {
    @Test func whenJSONBodyIsAttached_shouldCarryBytesGiven() throws {
        let bytes = Data(#"{"ticket": "ABCD-12"}"#.utf8)
        var request = try urlRequest()

        HTTPBody.json(bytes).attach(to: &request)

        #expect(request.httpBody == bytes)
    }

    @Test func whenJSONBodyIsAttached_shouldDeclareJSONContentType() throws {
        var request = try urlRequest()

        HTTPBody.json(Data()).attach(to: &request)

        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    private func urlRequest() throws -> URLRequest {
        URLRequest(url: try #require(URL(string: "https://example.com")))
    }
}
