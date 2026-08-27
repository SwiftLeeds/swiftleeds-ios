import Dependencies
import Foundation

extension AuthGateway: DependencyKey {
    package static var liveValue: AuthGateway {
        live.logging().narrowingFailures()
    }
}

extension AuthGateway {
    /// Throws ``LoginRequestError`` or ``LoginMapper/ResponseError``.
    static var live: AuthGateway {
        AuthGateway { credential in
            @Dependency(\.httpClient) var httpClient
            @Dependency(\.loginMapper) var loginMapper

            let body: Data
            do {
                body = try JSONEncoder().encode(LoginRequestDTO(credential))
            } catch {
                throw LoginRequestError.couldNotEncodeRequest(error)
            }
            let request = Endpoint.login(body: body).urlRequest()

            let data: Data
            let response: HTTPURLResponse
            do {
                (data, response) = try await httpClient.send(request)
            } catch {
                throw LoginRequestError.transportFailed(error)
            }

            return try loginMapper.map(data, response)
        }
    }

    /// Converts both seams' detailed failures to the bare error callers see.
    func narrowingFailures() -> AuthGateway {
        AuthGateway { credential in
            do {
                return try await authenticate(credential)
            } catch let error as LoginRequestError {
                throw SignInError(error)
            } catch let error as LoginMapper.ResponseError {
                throw SignInError(error)
            }
        }
    }
}
