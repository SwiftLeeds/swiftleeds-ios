import AuthenticationInfrastructure
import Foundation
import NetworkKit
import NetworkKitTestSupport
import Testing

@Suite struct HTTPClientSessionExpiryTests {
    /// A spy that records each run of the session expiry reaction.
    private actor ReactionSpy {
        /// A call the spy recorded.
        enum Action: Equatable {
            /// A run of the session expiry reaction.
            case expiryReported
        }

        /// The calls recorded so far, in order.
        private(set) var actions: [Action] = []

        /// Records that the session expiry reaction ran.
        func record() { actions.append(.expiryReported) }
    }

    private let url: URL

    init() throws {
        url = try #require(URL(string: "https://example.com"))
    }

    @Test func when401OnBearerRequest_shouldInvokeReaction() async throws {
        let reaction = ReactionSpy()
        var request = URLRequest(url: url)
        request.setValue("Bearer x", forHTTPHeaderField: "Authorization")

        _ = try await HTTPClient.responding(with: Data(), statusCode: 401)
            .interceptingSessionExpiry { await reaction.record() }
            .send(request)

        #expect(await reaction.actions == [.expiryReported])
    }

    @Test func when401WithoutBearer_shouldNotInvokeReaction() async throws {
        let reaction = ReactionSpy()
        let request = URLRequest(url: url)

        _ = try await HTTPClient.responding(with: Data(), statusCode: 401)
            .interceptingSessionExpiry { await reaction.record() }
            .send(request)

        #expect(await reaction.actions.isEmpty)
    }

    @Test func whenSuccessOnBearerRequest_shouldNotInvokeReaction() async throws {
        let reaction = ReactionSpy()
        var request = URLRequest(url: url)
        request.setValue("Bearer x", forHTTPHeaderField: "Authorization")

        _ = try await HTTPClient.responding(with: Data(), statusCode: 200)
            .interceptingSessionExpiry { await reaction.record() }
            .send(request)

        #expect(await reaction.actions.isEmpty)
    }
}
