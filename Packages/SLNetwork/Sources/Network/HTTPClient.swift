import Dependencies

public struct HTTPClient: Sendable {
    public var send: @Sendable (HTTPRequest) async throws -> HTTPResponse
}

#warning("TODO: Have `HTTPClient+Dependencies file to separate out `Dependencies` import")

extension HTTPClient: TestDependencyKey {
    public static var testValue: Self {
        HTTPClient(
            send: { _ in
                unimplemented("HTTPClient.send is unimplemented", placeholder: HTTPResponse(status: 0, body: Data()))
            }
        )
    }
}

extension DependencyValues {
    public var httpClient: HTTPClient {
        get { self[HTTPClient.self] }
        set { self[HTTPClient.self] = newValue }
    }
}

#warning("Consider replacing with Apple HTTP types")
#warning("Move to own files")

import Foundation

public struct HTTPRequest: Sendable {
    public enum Method: String, Sendable {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    public var method: Method
    public var path: String
    public var headers: [String: String]
    public var body: Data?

    public init(
        method: Method,
        path: String,
        headers: [String : String],
        body: Data? = nil
    ) {
        self.method = method
        self.path = path
        self.headers = headers
        self.body = body
    }
}

public struct HTTPResponse: Sendable {
    public let status: Int
    public let body: Data

    public init(
        status: Int,
        body: Data
    ) {
        self.status = status
        self.body = body
    }
}

public enum HTTPError: Error, Sendable, Equatable {
    case status(code: Int, body: Data)
    case transport
    case invalidResponse
}
