import Foundation

public struct Request<Response> {
    let scheme: String
    let host: String
    let path: String?
    let method: HttpMethod
    public var headers: [String: String] = [:]
    let eTagKey: String?
    let url: URL

    public init(
        scheme: String = "https",
        host: String,
        path: String,
        method: HttpMethod = .get([]),
        headers: [String: String] = [:],
        eTagKey: String? = nil
    ) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.method = method
        self.headers = headers
        self.eTagKey = eTagKey

        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path

        guard let url = components.url else {
            preconditionFailure("Couldn't create a url from components")
        }
        self.url = url
    }

    var urlRequest: URLRequest {
        var request = URLRequest(url: url)

        switch method {
        case let .get(queryItems):
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems

            guard let url = components?.url else {
                preconditionFailure("Couldn't create a url from components...")
            }

            request = URLRequest(url: url)
        case .post(let data):
            request.httpBody = data
        case .head:
            break
        }

        request.httpMethod = method.name
        request.allHTTPHeaderFields = headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("*", forHTTPHeaderField: "Accept-Encoding")

        if let eTagKey, let eTagValue = UserDefaults.standard.value(forKey: eTagKey) as? String {
            request.setValue(eTagValue, forHTTPHeaderField: "If-None-Match")
        }

        return request
    }
}
