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

    @Test(arguments: [
        (100, HTTPStatus.Category.informational),
        (199, HTTPStatus.Category.informational),
        (200, HTTPStatus.Category.successful),
        (299, HTTPStatus.Category.successful),
        (300, HTTPStatus.Category.redirection),
        (399, HTTPStatus.Category.redirection),
        (400, HTTPStatus.Category.clientError),
        (499, HTTPStatus.Category.clientError),
        (500, HTTPStatus.Category.serverError),
        (599, HTTPStatus.Category.serverError),
    ])
    func whenCodeIsInDefinedClass_shouldDeriveCategoryFromFirstDigit(
        code: Int,
        category: HTTPStatus.Category
    ) {
        #expect(HTTPStatus(code).category == category)
    }

    @Test(arguments: [99, 600, 0, -1, 1000])
    func whenCodeIsOutsideValidRange_shouldBeInvalid(code: Int) {
        #expect(HTTPStatus(code).category == .invalid)
    }
}
