//
//  Networking.swift
//

import Foundation
import Combine

public protocol Networking {
    func performRequest<E: Endpoint>(endpoint: E) -> AnyPublisher<E.DataType, NetworkError>
    init(environment: NetworkEnvironmentProviding, urlSession: URLSession)
}
