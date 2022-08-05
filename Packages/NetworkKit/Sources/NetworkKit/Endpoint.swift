//
//  Endpoint.swift
//

import Foundation

public enum HTTPMethod {
    case GET, POST, PUT, PATCH, DELETE
}

public protocol Endpoint {
    associatedtype DataType: Decodable

    var path: String { get }
    var method: HTTPMethod { get }
    var queryParameters: [URLQueryItem] { get }
    var pathParameters: [String] { get }

    func makeRequest(for environment: NetworkEnvironmentProviding) -> URLRequest?
}

public extension Endpoint {
    /// Default parameters so routes do not need to declare these
    var queryParameters: [URLQueryItem] {
        return []
    }
    var pathParameters: [String] {
        return []
    }

    /// The basic implementation of `Endpoint` `toRequest` builds the path. This should be usable with most instances of Endpoint.
    func makeRequest(for environment: NetworkEnvironmentProviding) -> URLRequest? {
        // Add all the parameters
        guard var urlComponents = URLComponents(string: environment.apiURL) else {
            return nil
        }
        urlComponents.queryItems = self.queryParameters
        
        guard var url = urlComponents.url?.appendingPathComponent(self.path) else {
            return nil
        }

        pathParameters.forEach {
            url.appendPathComponent($0)
        }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
