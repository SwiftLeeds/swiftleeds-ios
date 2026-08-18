import Dependencies
import Foundation

extension AuthGateway: DependencyKey {
    /// Order is load-bearing: logging must sit inside the narrowing, or it would see only
    /// `AuthenticationError` and the reason would already be gone.
    package static var liveValue: AuthGateway {
        live.loggingRequestFailures().narrowingFailures()
    }
}

extension AuthGateway {
    /// Throws `LoginRequestFailure` for anything that stops a response arriving, and lets the
    /// mapper's own `LoginResponseFailure` pass through.
    static var live: AuthGateway {
        AuthGateway { credential in
            @Dependency(\.httpClient) var httpClient
            @Dependency(\.apiConfiguration) var apiConfiguration
            @Dependency(\.loginMapper) var loginMapper

            var request = URLRequest(url: Endpoint.login.url(baseURL: apiConfiguration.baseURL))
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                request.httpBody = try JSONEncoder().encode(LoginRequestDTO(credential))
            } catch {
                throw LoginRequestFailure.couldNotEncodeRequest(error)
            }

            let data: Data
            let response: HTTPURLResponse
            do {
                (data, response) = try await httpClient.send(request)
            } catch {
                throw LoginRequestFailure.transportFailed(error)
            }

            return try loginMapper.map(data, response)
        }
    }

    /// Converts both seams' detailed failures to the bare error callers see.
    func narrowingFailures() -> AuthGateway {
        AuthGateway { credential in
            do {
                return try await authenticate(credential)
            } catch let failure as LoginRequestFailure {
                throw AuthenticationError(failure)
            } catch let failure as LoginResponseFailure {
                throw AuthenticationError(failure)
            }
        }
    }
}
