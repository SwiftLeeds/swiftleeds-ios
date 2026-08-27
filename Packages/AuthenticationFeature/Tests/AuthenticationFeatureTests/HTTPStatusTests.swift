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

    private static let registeredStatuses: [(HTTPStatus, Int)] = [
        (.continue, 100),
        (.switchingProtocols, 101),
        (.earlyHints, 103),
        (.ok, 200),
        (.created, 201),
        (.accepted, 202),
        (.nonAuthoritativeInformation, 203),
        (.noContent, 204),
        (.resetContent, 205),
        (.partialContent, 206),
        (.multipleChoices, 300),
        (.movedPermanently, 301),
        (.found, 302),
        (.seeOther, 303),
        (.notModified, 304),
        (.temporaryRedirect, 307),
        (.permanentRedirect, 308),
        (.badRequest, 400),
        (.unauthorized, 401),
        (.forbidden, 403),
        (.notFound, 404),
        (.methodNotAllowed, 405),
        (.notAcceptable, 406),
        (.proxyAuthenticationRequired, 407),
        (.requestTimeout, 408),
        (.conflict, 409),
        (.gone, 410),
        (.lengthRequired, 411),
        (.preconditionFailed, 412),
        (.contentTooLarge, 413),
        (.uriTooLong, 414),
        (.unsupportedMediaType, 415),
        (.rangeNotSatisfiable, 416),
        (.expectationFailed, 417),
        (.misdirectedRequest, 421),
        (.unprocessableContent, 422),
        (.tooEarly, 425),
        (.upgradeRequired, 426),
        (.preconditionRequired, 428),
        (.tooManyRequests, 429),
        (.requestHeaderFieldsTooLarge, 431),
        (.unavailableForLegalReasons, 451),
        (.internalServerError, 500),
        (.notImplemented, 501),
        (.badGateway, 502),
        (.serviceUnavailable, 503),
        (.gatewayTimeout, 504),
        (.httpVersionNotSupported, 505),
        (.networkAuthenticationRequired, 511),
    ]

    @Test(arguments: registeredStatuses)
    func whenStatusIsNamed_shouldHaveRegisteredCode(status: HTTPStatus, code: Int) {
        #expect(Int(status) == code)
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
