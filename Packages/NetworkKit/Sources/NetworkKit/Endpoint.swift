//
//  Endpoint.swift
//

import Foundation

public enum HTTPMethod: String {
    case GET, POST, PUT, PATCH, DELETE
}

public struct Empty: Codable { }

public protocol Endpoint {
    associatedtype DataType: Decodable
    associatedtype BodyType: Encodable

    var body: BodyType { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryParameters: [URLQueryItem] { get }
    var pathParameters: [String] { get }

    func makeRequest(for environment: NetworkEnvironmentProviding) -> URLRequest?
}

public extension Endpoint {
    var body: Empty? {
        return nil
    }
    
    /// Default parameters so routes do not need to declare these
    var method: HTTPMethod {
        .GET
    }

    var queryParameters: [URLQueryItem] {
        []
    }

    var pathParameters: [String] {
        []
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
        request.httpMethod = method.rawValue
        
        if let body = body {
            do {
                let encoder = JSONEncoder()
                request.httpBody = try encoder.encode(body)
            } catch {
                print("Unable to encode body to \(error.localizedDescription)")
            }
        }
                
        return request
    }
}
