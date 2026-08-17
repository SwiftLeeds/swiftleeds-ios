import Dependencies
import Foundation

extension AuthGateway: DependencyKey {
    package static var liveValue: AuthGateway {
        AuthGateway { credential in
            @Dependency(\.httpClient) var httpClient
            @Dependency(\.apiConfiguration) var apiConfiguration
            @Dependency(\.loginMapper) var loginMapper

            var request = URLRequest(url: Endpoint.login.url(baseURL: apiConfiguration.baseURL))
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let data: Data
            let response: HTTPURLResponse
            do {
                request.httpBody = try JSONEncoder().encode(LoginRequestDTO(credential))
                (data, response) = try await httpClient.send(request)
            } catch {
                throw AuthenticationError.unknown
            }
            do throws(LoginResponseFailure) {
                return try loginMapper.map(data, response)
            } catch {
                throw AuthenticationError(error)
            }
        }
    }
}
