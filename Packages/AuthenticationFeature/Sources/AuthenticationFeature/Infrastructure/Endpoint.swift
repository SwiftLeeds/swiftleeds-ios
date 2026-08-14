import Foundation

enum Endpoint {
    case login
    case profile

    func url(baseURL: URL) -> URL {
        switch self {
        case .login:
            baseURL.appending(path: "api/v1/login/ticket")
        case .profile:
            baseURL.appending(path: "api/v1/login/ticket")
        }
    }
}
