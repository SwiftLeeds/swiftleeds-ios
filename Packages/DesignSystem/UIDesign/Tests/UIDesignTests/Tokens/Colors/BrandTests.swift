import Testing
import UIDesign

/// Tests for parsing a ``Brand`` from the text an app declares.
struct BrandTests {
    /// Checks that the SwiftLeeds declaration returns the SwiftLeeds brand.
    @Test
    func whenDeclarationIsSwiftLeeds_shouldReturnSwiftLeeds() throws {
        let sut = try Brand("SwiftLeeds")

        #expect(sut == .swiftLeeds)
    }

    /// Checks that the KotlinLeeds declaration returns the KotlinLeeds brand.
    @Test
    func whenDeclarationIsKotlinLeeds_shouldReturnKotlinLeeds() throws {
        let sut = try Brand("KotlinLeeds")

        #expect(sut == .kotlinLeeds)
    }

    /// Checks that any other text throws an error carrying that same text.
    ///
    /// - Parameter text: The declaration to reject.
    @Test(arguments: ["swiftleeds", "KOTLINLEEDS", "MobileLeeds", " SwiftLeeds", ""])
    func whenDeclarationIsUnknown_shouldThrowUnknownBrandWithText(text: String) {
        #expect(throws: Brand.ParsingError.unknownBrand(text)) {
            try Brand(text)
        }
    }

    /// Checks that the Info.plist key is the one the apps declare.
    @Test
    func whenReadingKey_shouldReturnBrand() {
        #expect(Brand.infoDictionaryKey == "Brand")
    }

    /// Checks that a dictionary with no entries returns the SwiftLeeds brand.
    @Test
    func whenDictionaryIsEmpty_shouldReturnSwiftLeeds() throws {
        let sut = try Brand(infoDictionary: [:])

        #expect(sut == .swiftLeeds)
    }

    /// Checks that a dictionary with other keys but no brand returns the SwiftLeeds brand.
    @Test
    func whenDictionaryHasNoBrand_shouldReturnSwiftLeeds() throws {
        let sut = try Brand(infoDictionary: ["CFBundleName": "Example"])

        #expect(sut == .swiftLeeds)
    }

    /// Checks that a dictionary declaring SwiftLeeds returns the SwiftLeeds brand.
    @Test
    func whenDictionaryDeclaresSwiftLeeds_shouldReturnSwiftLeeds() throws {
        let sut = try Brand(infoDictionary: [Brand.infoDictionaryKey: "SwiftLeeds"])

        #expect(sut == .swiftLeeds)
    }

    /// Checks that a dictionary declaring KotlinLeeds returns the KotlinLeeds brand.
    @Test
    func whenDictionaryDeclaresKotlinLeeds_shouldReturnKotlinLeeds() throws {
        let sut = try Brand(infoDictionary: [Brand.infoDictionaryKey: "KotlinLeeds"])

        #expect(sut == .kotlinLeeds)
    }

    /// Checks that a dictionary declaring an unknown brand throws an error carrying the text.
    @Test
    func whenDictionaryDeclaresUnknownBrand_shouldThrowUnknownBrandWithText() {
        #expect(throws: Brand.ParsingError.unknownBrand("MobileLeeds")) {
            try Brand(infoDictionary: [Brand.infoDictionaryKey: "MobileLeeds"])
        }
    }

    /// Checks that a dictionary declaring something other than text throws an error carrying it.
    @Test
    func whenDictionaryDeclaresNonText_shouldThrowNotTextWithDescription() {
        #expect(throws: Brand.ParsingError.notText("42")) {
            try Brand(infoDictionary: [Brand.infoDictionaryKey: 42])
        }
    }
}
