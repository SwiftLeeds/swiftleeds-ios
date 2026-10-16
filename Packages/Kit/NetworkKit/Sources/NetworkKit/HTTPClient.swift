import Dependencies
import Foundation

public struct HTTPClient: Sendable {
    /// Why a response could not be used.
    public enum ResponseError: Error, Equatable {
        /// The transport answered, but not over HTTP.
        case notHTTP
    }

    public var send: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)

    public init(send: @escaping @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)) {
        self.send = send
    }
}

extension HTTPClient: TestDependencyKey {
    public static let testValue = HTTPClient(send: unimplemented("HTTPClient.send"))
}

extension DependencyValues {
    public var httpClient: HTTPClient {
        get { self[HTTPClient.self] }
        set { self[HTTPClient.self] = newValue }
    }
}
