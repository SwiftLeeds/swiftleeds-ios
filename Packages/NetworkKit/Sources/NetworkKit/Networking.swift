//
//  Networking.swift
//

import Foundation
import Combine

public protocol Networking {
    init(environment: NetworkEnvironmentProviding, urlSession: URLSession)

    func performRequest<E: Endpoint>(endpoint: E) -> AnyPublisher<E.DataType, NetworkError>
    func performRequest<E: Endpoint>(endpoint: E) async throws -> E.DataType
}
