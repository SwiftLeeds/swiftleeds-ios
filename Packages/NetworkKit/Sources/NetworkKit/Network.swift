//
//  Network.swift
//

import Foundation
import Combine

/// A simple implementation of `Networking` that should handle most use cases.
final public class Network: Networking {
    let environment: NetworkEnvironmentProviding
    let urlSession: URLSession

    required public init(environment: NetworkEnvironmentProviding, urlSession: URLSession = .shared) {
        self.environment = environment
        self.urlSession = urlSession
    }

    public func performRequest<E: Endpoint>(endpoint: E) async throws -> E.DataType {
        guard let request = endpoint.makeRequest(for: environment) else {
            throw NetworkError.other
        }

        do {
            let (data, response) = try await urlSession.data(for: request)
            try validateResponseCode(response: response)
            // Try to decode
            do {
                return try decoder.decode(E.DataType.self, from: data)
            } catch {
                throw NetworkError.failedToDecode
            }
        } catch {
            throw NetworkError.init(from: (error as NSError).code)
        }
    }

    private func validateResponseCode(response: URLResponse) throws {
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            throw NetworkError.badResponse
        }
        guard 200..<399  ~= statusCode else {
            throw NetworkError(from: statusCode)
        }
    }

    public func performRequest<E: Endpoint>(endpoint: E) -> AnyPublisher<E.DataType, NetworkError> {
        // If we can't make a request, fail early, and just emit a lazy failure.
        guard let request = endpoint.makeRequest(for: environment) else {
            return Deferred {
                Future { continuation in
                    continuation(.failure(.other))
                }
            }
            .eraseToAnyPublisher()
        }

        return urlSession.dataTaskPublisher(for: request)
            .mapError { NetworkError(from: $0) }
            .map(\.data)
            .decode(type: E.DataType.self, decoder: decoder)
            .mapError { err in
                return NetworkError(from: (err as NSError).code)
            }
            .eraseToAnyPublisher()
    }
    
    lazy var decoder: JSONDecoder = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
}
