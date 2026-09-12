import Foundation
import NetworkKit

enum StubFailure: Error {
    case couldNotBuildResponse
}

extension HTTPClient {
    static func responding(with data: Data, statusCode: Int) -> HTTPClient {
        HTTPClient { request in
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

    static func failing(with error: some Error & Sendable) -> HTTPClient {
        HTTPClient { _ in throw error }
    }

    static func recordingRequests(
        into recorder: RequestRecorder,
        responding data: Data
    ) -> HTTPClient {
        HTTPClient { request in
            await recorder.record(request)
            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  )
            else { throw StubFailure.couldNotBuildResponse }
            return (data, response)
        }
    }
}

actor RequestRecorder {
    private(set) var requests: [URLRequest] = []

    func record(_ request: URLRequest) {
        requests.append(request)
    }
}
