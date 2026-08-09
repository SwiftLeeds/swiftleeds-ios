import Dependencies
import Foundation

package struct HTTPClient: Sendable {
    package var send: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)

    package init(send: @escaping @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)) {
        self.send = send
    }
}

extension HTTPClient: TestDependencyKey {
    package static let testValue = HTTPClient(send: unimplemented("HTTPClient.send"))
}

extension DependencyValues {
    package var httpClient: HTTPClient {
        get { self[HTTPClient.self] }
        set { self[HTTPClient.self] = newValue }
    }
}
