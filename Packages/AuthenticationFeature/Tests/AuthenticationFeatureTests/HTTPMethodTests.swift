import AuthenticationFeature
import Testing

@Suite struct HTTPMethodTests {
    private static let registeredMethods: [(HTTPMethod, String)] = [
        (.get, "GET"),
        (.head, "HEAD"),
        (.post, "POST"),
        (.put, "PUT"),
        (.delete, "DELETE"),
        (.connect, "CONNECT"),
        (.options, "OPTIONS"),
        (.trace, "TRACE"),
        (.patch, "PATCH"),
    ]

    @Test(arguments: registeredMethods)
    func whenMethodIsNamed_shouldHaveRegisteredToken(method: HTTPMethod, token: String) {
        #expect(method.rawValue == token)
    }
}
