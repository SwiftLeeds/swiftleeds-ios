#if canImport(CoreImage)
import CoreGraphics
import Foundation
import ImageIO

/// Loads the picture of a code from an address.
///
/// The picture is decoded from the first frame of the image the server sends. The image's EXIF
/// orientation is not applied, and an animated image draws its first frame.
///
/// ```swift
/// let image = try await BarcodeLoader.live.load(URLRequest(url: codeURL))
/// ```
package struct BarcodeLoader: Sendable {
    /// The reason a load gave no picture.
    package enum LoadingError: Error, Equatable, Sendable {
        /// The session could not finish the transfer, or the task was cancelled.
        case transportFailed

        /// The server answered with a status outside 200 to 299.
        case unacceptableStatus

        /// The bytes are not an image.
        case undecodable

        /// CoreImage drew no marks from the image.
        case notDrawn
    }

    /// The loader the app uses: it sends requests with the shared session.
    package static let live = urlSession(.shared)

    /// The statuses that count as a success.
    private static let successStatuses = 200..<300

    /// The position of the frame to draw: the first one.
    private static let firstFrame = 0

    /// Loads the picture of a code.
    ///
    /// The status is checked first. A response that is not HTTP, such as one for a `data:` address,
    /// passes. The decoding and the thresholding run off the main actor.
    ///
    /// - Parameter request: The request for the image, headers included.
    /// - Returns: The picture as black marks on clear.
    /// - Throws: ``LoadingError/transportFailed`` when the session fails or the task is cancelled.
    ///   ``LoadingError/unacceptableStatus`` when the status is not 200 to 299.
    ///   ``LoadingError/undecodable`` when the bytes are not an image.
    ///   ``LoadingError/notDrawn`` when CoreImage draws no marks from the image.
    package var load: @Sendable (URLRequest) async throws(LoadingError) -> SuppliedBarcodeImage

    /// Returns a loader that fetches each image with a session.
    ///
    /// The session's own cache is the only cache. The loader keeps no images.
    ///
    /// - Parameter session: The session that sends each request.
    /// - Returns: A loader that sends its requests with `session`.
    package static func urlSession(_ session: URLSession) -> Self {
        Self { (request: URLRequest) async throws(LoadingError) -> SuppliedBarcodeImage in
            let (data, response) = try await transfer(request, over: session)
            try requireSuccess(of: response)
            return try await picture(from: data)
        }
    }

    /// Sends a request and returns the bytes and the response.
    ///
    /// - Parameters:
    ///   - request: The request to send.
    ///   - session: The session that sends it.
    /// - Returns: The body and the response.
    /// - Throws: ``LoadingError/transportFailed`` when the session throws, cancellation included.
    private static func transfer(
        _ request: URLRequest,
        over session: URLSession,
    ) async throws(LoadingError) -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw .transportFailed
        }
    }

    /// Checks that an HTTP response has a success status.
    ///
    /// - Parameter response: The response to check. One that is not HTTP passes.
    /// - Throws: ``LoadingError/unacceptableStatus`` when the status is not 200 to 299.
    private static func requireSuccess(of response: URLResponse) throws(LoadingError) {
        guard let http = response as? HTTPURLResponse else { return }
        guard successStatuses.contains(http.statusCode) else { throw .unacceptableStatus }
    }

    /// Decodes the first frame of an image and turns it into black marks on clear.
    ///
    /// - Parameter data: The bytes of the image.
    /// - Returns: The picture as black marks on clear.
    /// - Throws: ``LoadingError/undecodable`` when the bytes are not an image.
    ///   ``LoadingError/notDrawn`` when CoreImage draws no marks from the image.
    @concurrent
    private static func picture(from data: Data) async throws(LoadingError) -> SuppliedBarcodeImage {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
            let decoded = CGImageSourceCreateImageAtIndex(source, firstFrame, nil)
        else { throw .undecodable }
        do {
            return try SuppliedBarcodeImage(decoded)
        } catch {
            throw .notDrawn
        }
    }
}
#endif
