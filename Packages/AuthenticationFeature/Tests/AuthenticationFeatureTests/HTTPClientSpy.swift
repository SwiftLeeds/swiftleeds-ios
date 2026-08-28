import AuthenticationFeature
import Foundation
import NetworkKit

actor HTTPClientSpy {
    private(set) var requests: [URLRequest] = []
    private let data: Data
    private let statusCode: Int

    init(respondingWith data: Data, statusCode: Int) {
        self.data = data
        self.statusCode = statusCode
    }

    nonisolated var httpClient: HTTPClient {
        HTTPClient { request in try await self.handle(request) }
    }

    private func handle(_ request: URLRequest) throws -> (Data, HTTPURLResponse) {
        requests.append(request)
        guard let url = request.url,
              let response = HTTPURLResponse(
                  url: url,
                  statusCode: statusCode,
                  httpVersion: nil,
                  headerFields: nil
              )
        else { throw StubFailure.couldNotBuildResponse }
        return (data, response)
    }
}
