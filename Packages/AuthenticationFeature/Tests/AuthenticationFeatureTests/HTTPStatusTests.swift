import AuthenticationFeature
import Testing

@Suite struct HTTPStatusTests {
    @Test func whenCodesMatch_shouldBeEqual() {
        #expect(HTTPStatus(503) == HTTPStatus(503))
    }

    @Test func whenCodesDiffer_shouldNotBeEqual() {
        #expect(HTTPStatus(200) != HTTPStatus(401))
    }

    @Test func whenCodeIsExtracted_shouldReturnCodeGiven() {
        #expect(Int(HTTPStatus(418)) == 418)
    }

    @Test func whenStatusIsOK_shouldHaveCode200() {
        #expect(Int(HTTPStatus.ok) == 200)
    }

    @Test func whenStatusIsUnauthorized_shouldHaveCode401() {
        #expect(Int(HTTPStatus.unauthorized) == 401)
    }
}
