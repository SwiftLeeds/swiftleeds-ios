import Foundation
import NetworkKit
import Testing

@Suite struct HTTPFieldNameTests {
    @Test func whenNamesDifferOnlyByCase_shouldBeEqual() {
        #expect(HTTPField.Name("Accept") == HTTPField.Name("accept"))
    }

    @Test func whenNamesDifferOnlyByCase_shouldHashAlike() {
        let names: Set<HTTPField.Name> = [HTTPField.Name("Accept"), HTTPField.Name("ACCEPT")]

        #expect(names.count == 1)
    }

    @Test func whenNamesDiffer_shouldNotBeEqual() {
        #expect(HTTPField.Name("Accept") != HTTPField.Name("Accept-Encoding"))
    }

    @Test func whenNameIsExtracted_shouldKeepCasingGiven() {
        #expect(String(HTTPField.Name("If-None-Match")) == "If-None-Match")
    }

    @Test func whenAcceptIsUsed_shouldNameAcceptHeader() {
        #expect(String(HTTPField.Name.accept) == "Accept")
    }
}
