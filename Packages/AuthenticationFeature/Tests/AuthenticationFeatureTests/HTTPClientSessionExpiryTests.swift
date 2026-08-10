import AuthenticationFeature
import Foundation
import Testing

@Suite struct HTTPClientSessionExpiryTests {
    private let url = URL(string: "https://example.com")!

    @Test func when401OnBearerRequest_shouldInvokeReaction() async throws {
        let reaction = ReactionSpy()
        var request = URLRequest(url: url)
        request.setValue("Bearer x", forHTTPHeaderField: "Authorization")

        _ = try await HTTPClient.responding(with: Data(), statusCode: 401)
            .interceptingSessionExpiry { await reaction.record() }
            .send(request)

        #expect(await reaction.count == 1)
    }

    @Test func when401WithoutBearer_shouldNotInvokeReaction() async throws {
        let reaction = ReactionSpy()
        let request = URLRequest(url: url)

        _ = try await HTTPClient.responding(with: Data(), statusCode: 401)
            .interceptingSessionExpiry { await reaction.record() }
            .send(request)

        #expect(await reaction.count == 0)
    }

    @Test func whenSuccessOnBearerRequest_shouldNotInvokeReaction() async throws {
        let reaction = ReactionSpy()
        var request = URLRequest(url: url)
        request.setValue("Bearer x", forHTTPHeaderField: "Authorization")

        _ = try await HTTPClient.responding(with: Data(), statusCode: 200)
            .interceptingSessionExpiry { await reaction.record() }
            .send(request)

        #expect(await reaction.count == 0)
    }
}

private actor ReactionSpy {
    private(set) var count = 0
    func record() { count += 1 }
}
