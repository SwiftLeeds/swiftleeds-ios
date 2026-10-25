import Foundation

/// A spy that records each request an `HTTPClient` is given.
actor HTTPClientSpy {
    /// The requests the client was given, in order.
    private(set) var requests: [URLRequest] = []

    /// Records a request the client was given.
    ///
    /// - Parameter request: The request the client was given.
    func record(_ request: URLRequest) {
        requests.append(request)
    }
}
