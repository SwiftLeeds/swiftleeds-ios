#if canImport(CoreImage)
import Foundation

/// Answers every HTTP request of a session with one made-up answer.
///
/// Only the tests of the loader that wraps `URLSession` may use it.
final class URLProtocolStub: URLProtocol {
    /// What the stub answers a request with.
    enum Answer {
        /// A response with a status code and a body.
        ///
        /// Both values mirror the `HTTPURLResponse` and `Data` the session itself hands out.
        case response(statusCode: Int, data: Data)

        /// A transport failure.
        case failure(URLError)
    }

    /// The answer to give.
    ///
    /// Set it before a request starts.
    nonisolated(unsafe) static var answer: Answer?

    /// The request the stub most recently served.
    nonisolated(unsafe) static var lastRequest: URLRequest?

    /// Forgets the answer and the last request, so neither can reach a later test.
    static func removeAnswer() {
        answer = nil
        lastRequest = nil
    }

    /// Returns an ephemeral session that sends every HTTP request to the stub.
    ///
    /// - Returns: A session with no cache and no stored cookies.
    static func session() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }

    /// Returns whether the stub takes a request: it takes only `http` and `https`.
    ///
    /// - Parameter request: The request to check.
    /// - Returns: `true` for an `http` or `https` request.
    override static func canInit(with request: URLRequest) -> Bool {
        request.url?.scheme == "http" || request.url?.scheme == "https"
    }

    /// Returns the request unchanged.
    ///
    /// - Parameter request: The request to return.
    /// - Returns: `request`.
    override static func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    /// Answers the request with the current answer.
    override func startLoading() {
        Self.lastRequest = request
        switch Self.answer {
        case let .response(statusCode, data):
            deliver(statusCode: statusCode, data: data)

        case .failure(let error):
            client?.urlProtocol(self, didFailWithError: error)

        case nil:
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
        }
    }

    /// Does nothing: the stub has already answered when loading started.
    override func stopLoading() {}  // swiftlint:disable:this no_empty_block - a required override with nothing to stop

    /// Hands the session a response and its body, then finishes.
    ///
    /// - Parameters:
    ///   - statusCode: The status code of the response.
    ///   - data: The body of the response.
    private func deliver(statusCode: Int, data: Data) {
        guard let url = request.url,
            let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
}
#endif
