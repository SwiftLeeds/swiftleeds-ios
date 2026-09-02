import Foundation

final class URLProtocolStub: URLProtocol {
    struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }

    nonisolated(unsafe) static var stub: Stub?

    // The request the stub most recently served.
    nonisolated(unsafe) static var lastRequest: URLRequest?

    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error)
    }

    /// Forgets the current stub and the last request, so neither can reach a later test.
    static func removeStub() {
        stub = nil
        lastRequest = nil
    }

    static func session() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.lastRequest = request
        if let error = Self.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let data = Self.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = Self.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}
