import Foundation

public extension URLSession {
    static var awaitConnectivity: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return URLSession(configuration: configuration)
    }()

    func decode<Response: Decodable>(
        _ request: Request<Response>,
        using decoder: JSONDecoder = .init(),
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy?,
        fileManager: FileManager = .default,
        filename: String? = nil
    ) async throws -> Response {
        let filename = filename ?? request.url.lastPathComponent
        let path = fileManager.temporaryDirectory.appendingPathComponent("\(filename).json")

        let decoded = Task.detached(priority: .userInitiated) {
            do {
                let (data, response) = try await self.data(for: request.urlRequest)

                try Task.checkCancellation()

                guard let response = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                switch response.statusCode {
                case 200...299: break
                case 304: throw NetworkError.notModified
                default: throw NetworkError.unexpectedStatusCode(response.statusCode)
                }
                
                let cachedResponse = CachedURLResponse(
                    response: response,
                    data: data
                )
                URLCache.shared.storeCachedResponse(
                    cachedResponse,
                    for: request.urlRequest
                )

                try data.write(
                    to: path,
                    options: .atomicWrite
                )

                if let eTagKey = request.eTagKey, let eTagValue = response.value(forHTTPHeaderField: "Etag") {
                    UserDefaults.standard.set(eTagValue, forKey: eTagKey)
                }

                if let dateDecodingStrategy {
                    decoder.dateDecodingStrategy = dateDecodingStrategy
                }

                return try decoder.decode(Response.self, from: data)
            } catch {
                let nsError = error as NSError

                if let networkIssue = NetworkError.NetworkIssue(rawValue: nsError.code) {
                    throw NetworkError.networkIssue(networkIssue)
                }

                throw NetworkError.unexpectedError(error)
            }
        }

        return try await decoded.value
    }
}

// MARK: - NetworkError
public enum NetworkError: Error {
    case cacheNotFound
    case notModified
    case unexpectedStatusCode(Int)
    case unexpectedError(Error)
    case networkIssue(NetworkIssue)

    public enum NetworkIssue: Int, CaseIterable {
        case backgroundSessionInUseByAnotherProcess = -996
        case timedOut = -1001
        case cannotFindHost = -1003
        case cannotConnectToHost = -1004
        case networkConnectionLost = -1005
        case notConnectedToInternet =  -1009
        case secureConnectionFailed = -1200
    }
}
