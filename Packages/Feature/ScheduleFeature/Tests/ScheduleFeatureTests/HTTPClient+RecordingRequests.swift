import Foundation
import NetworkKit
import NetworkKitTestSupport

extension HTTPClient {
    static func recordingRequests(
        into spy: HTTPClientSpy,
        responding data: Data,
    ) -> HTTPClient {
        HTTPClient { request in
            await spy.record(request)
            guard let url = request.url,
                let response = HTTPURLResponse(
                    url: url,
                    statusCode: 200,  // swiftlint:disable:this no_magic_numbers - fixture data
                    httpVersion: nil,
                    headerFields: nil,
                )
            else { throw StubError.couldNotBuildResponse }
            return (data, response)
        }
    }
}
