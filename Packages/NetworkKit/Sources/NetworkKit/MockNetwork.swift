//
//  MockNetwork.swift
//

import Foundation
import Combine

/// A fully featured mock for `Networking` that allows injection of any error or data, from any endpoint.
/// The endpoint itself is ignored, and the provided data or error is emitted instead.
public class MockNetwork: Networking {

    private let environment: NetworkEnvironmentProviding
    private let urlSession: URLSession
    private var mockData: Decodable?
    private var mockError: NetworkError?

    required public init(environment: NetworkEnvironmentProviding, urlSession: URLSession) {
        self.environment = environment
        self.urlSession = urlSession
    }

    public func performRequest<E>(endpoint: E) -> AnyPublisher<E.DataType, NetworkError> where E: Endpoint {
        Deferred {
            Future { handler in
                if let mockData = self.mockData as? E.DataType {
                    handler(.success(mockData))
                } else if let mockError = self.mockError {
                    handler(.failure(mockError))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// Sets up the network handlers to return success with the provided `Decodable` provided that it matches the `Endpoint` data type.
    /// Takes precedence over `injectMockError`, in cases where both are provided the success will be returned.
    func injectMockData(data: Decodable) {
        self.mockData = data
    }

    /// Sets up the network handlers to return failure with the provided `NetworkError`
    func injectMockError(error: NetworkError) {
        self.mockError = error
    }

}
