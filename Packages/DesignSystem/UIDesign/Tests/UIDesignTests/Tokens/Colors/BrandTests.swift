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
}
