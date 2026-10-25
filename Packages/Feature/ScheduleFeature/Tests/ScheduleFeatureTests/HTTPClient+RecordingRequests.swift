import Foundation
import NetworkKit
import NetworkKitTestSupport

extension HTTPClient {
    /// Creates a client that records each request and answers every one with status 200.
    ///
    /// A request carrying no URL throws ``StubError/couldNotBuildResponse``.
    ///
    /// - Parameters:
    ///   - spy: The spy that receives each request.
    ///   - data: The body returned for every request.
    /// - Returns: A client that records into `spy` and returns `data` with status 200.
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
