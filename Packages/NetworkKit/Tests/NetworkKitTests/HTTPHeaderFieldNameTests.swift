import Foundation
import NetworkKit
import Testing

@Suite struct HTTPHeaderFieldNameTests {
    @Test func whenNamesDifferOnlyByCase_shouldBeEqual() {
        #expect(HTTPHeaderField.Name("Accept") == HTTPHeaderField.Name("accept"))
    }

    @Test func whenNamesDifferOnlyByCase_shouldHashAlike() {
        let names: Set<HTTPHeaderField.Name> = [HTTPHeaderField.Name("Accept"), HTTPHeaderField.Name("ACCEPT")]

        #expect(names.count == 1)
    }

    @Test func whenNamesDiffer_shouldNotBeEqual() {
        #expect(HTTPHeaderField.Name("Accept") != HTTPHeaderField.Name("Accept-Encoding"))
    }

    @Test func whenNameIsExtracted_shouldKeepCasingGiven() {
        #expect(String(HTTPHeaderField.Name("If-None-Match")) == "If-None-Match")
    }

    private static let registeredNames: [(HTTPHeaderField.Name, String)] = [
        (.accept, "Accept"),
        (.acceptEncoding, "Accept-Encoding"),
        (.acceptLanguage, "Accept-Language"),
        (.acceptRanges, "Accept-Ranges"),
        (.age, "Age"),
        (.allow, "Allow"),
        (.authenticationInfo, "Authentication-Info"),
        (.authorization, "Authorization"),
        (.cacheControl, "Cache-Control"),
        (.connection, "Connection"),
        (.contentEncoding, "Content-Encoding"),
        (.contentLanguage, "Content-Language"),
        (.contentLength, "Content-Length"),
        (.contentLocation, "Content-Location"),
        (.contentRange, "Content-Range"),
        (.contentType, "Content-Type"),
        (.date, "Date"),
        (.eTag, "ETag"),
        (.expect, "Expect"),
        (.expires, "Expires"),
        (.from, "From"),
        (.host, "Host"),
        (.ifMatch, "If-Match"),
        (.ifModifiedSince, "If-Modified-Since"),
        (.ifNoneMatch, "If-None-Match"),
        (.ifRange, "If-Range"),
        (.ifUnmodifiedSince, "If-Unmodified-Since"),
        (.lastModified, "Last-Modified"),
        (.location, "Location"),
        (.maxForwards, "Max-Forwards"),
        (.proxyAuthenticate, "Proxy-Authenticate"),
        (.proxyAuthenticationInfo, "Proxy-Authentication-Info"),
        (.proxyAuthorization, "Proxy-Authorization"),
        (.range, "Range"),
        (.referer, "Referer"),
        (.retryAfter, "Retry-After"),
        (.server, "Server"),
        (.te, "TE"),
        (.trailer, "Trailer"),
        (.upgrade, "Upgrade"),
        (.userAgent, "User-Agent"),
        (.vary, "Vary"),
        (.via, "Via"),
        (.wwwAuthenticate, "WWW-Authenticate"),
    ]

    @Test(arguments: registeredNames)
    func whenRegisteredNameIsExtracted_shouldSpellHeaderFieldItRegisters(
        name: HTTPHeaderField.Name,
        spelling: String
    ) {
        #expect(String(name) == spelling)
    }

    @Test func whenNamesAreRegistered_shouldCoverEveryHeaderFieldTheRFCsDefine() {
        #expect(Self.registeredNames.count == 44)
    }
}
