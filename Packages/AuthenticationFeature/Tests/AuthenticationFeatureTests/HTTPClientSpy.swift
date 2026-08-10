import AuthenticationFeature
import Foundation

actor HTTPClientSpy {
    private(set) var requests: [URLRequest] = []
    private let data: Data
    private let statusCode: Int

    init(respondingWith data: Data, statusCode: Int) {
        self.data = data
        self.statusCode = statusCode
    }

    nonisolated var httpClient: HTTPClient {
        HTTPClient { request in await self.handle(request) }
    }

    private func handle(_ request: URLRequest) -> (Data, HTTPURLResponse) {
        requests.append(request)
        let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        return (data, response)
    }
}
