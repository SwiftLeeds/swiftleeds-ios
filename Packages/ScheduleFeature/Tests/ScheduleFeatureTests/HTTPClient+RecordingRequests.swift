import Foundation
import NetworkKit
import NetworkKitTestSupport

extension HTTPClient {
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
            else { throw StubError.couldNotBuildResponse }
            return (data, response)
        }
    }
}
