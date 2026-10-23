import AuthenticationFeature
import Dependencies
import Foundation
import LogKit
import LogKitTestSupport
import NetworkKit
import NetworkKitTestSupport
import SecureStorageKit
import Testing

/// Checks that the live `SignIn` reaches the live gateway and the live session store.
@Suite struct SignInIntegrationTests {
    /// The stored session proves the live store ran, because the unstubbed store reports an issue.
    @Test func whenResolvedInLiveContext_shouldStoreSessionFromServer() async throws {
        let spy = SecureStorageSpy()
        let configuration = APIConfiguration(baseURL: try #require(URL(string: "https://example.com")))

        let session = try await withDependencies {
            $0.context = .live
            $0.authHTTPClient = .responding(with: Data("jwt-abc-123".utf8), statusCode: 200)
            $0.secureStorage = spy.secureStorage
            $0.apiConfiguration = configuration
            $0.log = LogRecorder().log
        } operation: {
            @Dependency(\.signIn) var sut
            @Dependency(\.sessionStore) var sessionStore
            try await sut(Credential.fixture)
            return try await sessionStore.current()
        }

        #expect(session == Session(token: try SessionToken("jwt-abc-123")))
    }
}
