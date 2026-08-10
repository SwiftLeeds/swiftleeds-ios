import Foundation

enum Endpoint {
    case profile

    func url(baseURL: URL) -> URL {
        switch self {
        // The backend overloads `login/ticket` (GET) as the profile endpoint.
        case .profile: baseURL.appending(path: "api/v1/login/ticket")
        }
    }
}
