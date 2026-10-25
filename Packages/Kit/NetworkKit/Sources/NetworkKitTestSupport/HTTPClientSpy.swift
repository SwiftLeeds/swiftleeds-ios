import Foundation
import NetworkKit

/// A spy that records each request its client receives, and answers each the same way.
public actor HTTPClientSpy {
    /// A call the client received.
    public enum Action: Equatable, Sendable {
        /// A request the client was asked to send.
        case send(URLRequest)
    }

    /// The calls received, in order.
    public private(set) var actions: [Action] = []

    /// The request each call carried, in order.
    ///
    /// - Complexity: O(*n*), where *n* is the number of calls received.
    public var requests: [URLRequest] {
        actions.map { action in
            switch action {
            case .send(let request): request
            }
        }
    }

    /// The body returned for every request.
    private let data: Data

    /// The status code returned for every request.
    private let statusCode: HTTPStatusCode

    /// A client that records each request into this spy and answers it.
    ///
    /// A request carrying no URL throws ``StubError/couldNotBuildResponse``.
    nonisolated public var httpClient: HTTPClient {
        HTTPClient { request in try await self.send(request) }
    }

    /// Creates a spy that answers every request with the same body and status code.
    ///
    /// ```swift
    /// let spy = HTTPClientSpy(respondingWith: Data(), statusCode: 200)
    /// try await withDependencies {
    ///     $0.httpClient = spy.httpClient
    /// } operation: {
    ///     try await sut.fetch()
    /// }
    /// #expect(await spy.actions == [.send(expected)])
    /// ```
    ///
    /// - Parameters:
    ///   - data: The body to return.
    ///   - statusCode: The status code to return.
    public init(respondingWith data: Data, statusCode: HTTPStatusCode) {
        self.data = data
        self.statusCode = statusCode
    }

    /// Records the request and builds its response.
    ///
    /// - Parameter request: The request the client was asked to send.
    /// - Returns: The body and a response carrying the status code.
    /// - Throws: ``StubError/couldNotBuildResponse`` when the request carries no URL.
    private func send(_ request: URLRequest) throws(StubError) -> (Data, HTTPURLResponse) {
        actions.append(.send(request))
        guard let url = request.url,
            let response = HTTPURLResponse(
                url: url,
                statusCode: Int(statusCode),
                httpVersion: nil,
                headerFields: nil,
            )
        else { throw .couldNotBuildResponse }
        return (data, response)
    }
}
