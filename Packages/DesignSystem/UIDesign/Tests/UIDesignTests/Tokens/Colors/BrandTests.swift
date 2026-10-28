import Foundation
import SwiftUI
import Testing
import UIDesign

#if canImport(AppKit)
import AppKit
#endif

/// Tests for parsing a ``Brand`` from the text an app declares, and for its surface colors.
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

#if canImport(AppKit)
extension BrandTests {
    /// A surface a brand tints, paired with the macOS color it copies the lightness of.
    private enum Surface: CaseIterable {
        /// The color for the main background of an interface.
        case surface
        /// The color for content layered on top of the main background.
        case secondarySurface
        /// The color for content layered on top of secondary backgrounds.
        case tertiarySurface
        /// The color for the main background of a grouped interface.
        case groupedSurface
        /// The color for content layered on top of the main background of a grouped interface.
        case secondaryGroupedSurface
        /// The color for content layered on top of secondary backgrounds of a grouped interface.
        case tertiaryGroupedSurface

        /// The key the generator's `APPLE_SURFACES` table uses for this surface.
        var key: String {
            switch self {
            case .surface: "surface"
            case .secondarySurface: "secondarySurface"
            case .tertiarySurface: "tertiarySurface"
            case .groupedSurface: "groupedSurface"
            case .secondaryGroupedSurface: "secondaryGroupedSurface"
            case .tertiaryGroupedSurface: "tertiaryGroupedSurface"
            }
        }

        /// The Apple color this surface copies the lightness of.
        ///
        /// macOS has no grouped backgrounds, so a grouped surface copies its plain counterpart.
        var apple: NSColor {
            switch self {
            case .surface: .windowBackgroundColor
            case .secondarySurface: .controlBackgroundColor
            case .tertiarySurface: .underPageBackgroundColor
            case .groupedSurface: .windowBackgroundColor
            case .secondaryGroupedSurface: .controlBackgroundColor
            case .tertiaryGroupedSurface: .underPageBackgroundColor
            }
        }

        /// Returns the brand's color for this surface.
        ///
        /// - Parameter brand: The brand to read.
        /// - Returns: The brand's tinted surface.
        func color(of brand: Brand) -> NSColor {
            switch self {
            case .surface: NSColor(brand.surface)
            case .secondarySurface: NSColor(brand.secondarySurface)
            case .tertiarySurface: NSColor(brand.tertiarySurface)
            case .groupedSurface: NSColor(brand.groupedSurface)
            case .secondaryGroupedSurface: NSColor(brand.secondaryGroupedSurface)
            case .tertiaryGroupedSurface: NSColor(brand.tertiaryGroupedSurface)
            }
        }
    }

    /// One way macOS can draw a color, in the generator's order.
    private enum MacAppearance: CaseIterable {
        /// Light mode.
        case light
        /// Dark mode.
        case dark
        /// Light mode with Increase Contrast.
        case lightIncreasedContrast
        /// Dark mode with Increase Contrast.
        case darkIncreasedContrast

        /// The name that failure messages use.
        var label: String {
            switch self {
            case .light: "light"
            case .dark: "dark"
            case .lightIncreasedContrast: "light with Increase Contrast"
            case .darkIncreasedContrast: "dark with Increase Contrast"
            }
        }

        /// The AppKit appearance that draws this way.
        var name: NSAppearance.Name {
            switch self {
            case .light: .aqua
            case .dark: .darkAqua
            case .lightIncreasedContrast: .accessibilityHighContrastAqua
            case .darkIncreasedContrast: .accessibilityHighContrastDarkAqua
            }
        }
    }

    /// How far a surface's lightness may sit from Apple's.
    private static let lightnessTolerance = 0.003
    /// How far a surface's chroma may sit from the brand's tint.
    private static let chromaTolerance = 0.0005
    /// How far a surface's hue may sit from the brand's hue, in degrees.
    private static let hueTolerance = 6.0
    /// How far a role's lightness may sit from its tone.
    private static let roleLightnessTolerance = 0.01
    /// How far a role's hue may sit from the brand's hue, in degrees.
    private static let roleHueTolerance = 3.0
    /// The lightness range in which a color is neither too dark nor too light to hold a tint.
    private static let tintableLightness = 0.05...0.98
    /// The largest value of one color component in a hex code.
    private static let hexScale: Float = 255
    /// The major version of macOS that the catalog's Mac surfaces were sampled on.
    private static let sampledMacOSMajorVersion = 27
    /// Whether this Mac runs the macOS version the catalog sampled, or a later one.
    private static let runsOnSampledMacOSOrLater = ProcessInfo.processInfo.isOperatingSystemAtLeast(
        OperatingSystemVersion(majorVersion: sampledMacOSMajorVersion, minorVersion: 0, patchVersion: 0)
    )

    /// Returns the components a color has under an appearance.
    ///
    /// - Parameters:
    ///   - color: The color to resolve.
    ///   - appearance: The appearance to resolve it under.
    /// - Returns: The color as fixed components.
    /// - Throws: When macOS has no appearance with the appearance's name.
    @MainActor
    private static func resolve(_ color: NSColor, in appearance: MacAppearance) throws -> Color.Resolved {
        let named = try #require(NSAppearance(named: appearance.name))
        var fixed = color.cgColor
        named.performAsCurrentDrawingAppearance { fixed = color.cgColor }
        return Color(cgColor: fixed).resolve(in: EnvironmentValues())
    }

    /// Returns a color as six hex digits in sRGB, such as `F2F2F7`.
    ///
    /// - Parameter color: The color to write.
    /// - Returns: The hex digits, without a leading `#`.
    private static func hex(of color: Color.Resolved) -> String {
        [color.red, color.green, color.blue]
            .map { String(format: "%02X", Int((min(max($0, 0), 1) * hexScale).rounded())) }
            .joined()
    }

    /// Returns Apple's live surfaces in the syntax of the generator's `APPLE_SURFACES` table.
    ///
    /// - Returns: One line per surface, ready to paste as its `mac` entry.
    @MainActor
    private static func appleSurfaceReport() throws -> String {
        let lines = try Surface.allCases.map { surface in
            let codes = try MacAppearance.allCases.map { "\"\(hex(of: try resolve(surface.apple, in: $0)))\"" }
            return "        \"mac\": (\(codes.joined(separator: ", "))),  # \(surface.key)"
        }
        let order = MacAppearance.allCases.map(\.label).joined(separator: ", ")
        return "Apple's macOS surfaces (\(order)):\n" + lines.joined(separator: "\n")
    }

    /// Checks that each surface keeps the lightness Apple's matching color has, and is opaque.
    ///
    /// - Parameter brand: The brand to check.
    /// - Throws: When macOS has no appearance that the check resolves under.
    @MainActor
    @Test(
        .enabled(
            if: Self.runsOnSampledMacOSOrLater,
            "The Mac surfaces were sampled on macOS \(Self.sampledMacOSMajorVersion)",
        ),
        arguments: Brand.allCases,
    )
    func whenSurfaceResolves_shouldKeepAppleLightness(brand: Brand) throws {
        var drifted: [String] = []
        for surface in Surface.allCases {
            for appearance in MacAppearance.allCases {
                let mine = try Self.resolve(surface.color(of: brand), in: appearance)
                let apple = try Self.resolve(surface.apple, in: appearance)
                let gap = abs(OKLCH(mine).lightness - OKLCH(apple).lightness)
                if gap > Self.lightnessTolerance || mine.opacity != 1 {
                    drifted.append("\(surface.key) \(appearance.label)")
                }
            }
        }
        let report = try Self.appleSurfaceReport()
        #expect(drifted.isEmpty, "\(brand) drifted from Apple in \(drifted). \(report)")
    }

    /// Checks that each surface Apple leaves room to tint takes the brand's hue and chroma.
    ///
    /// - Parameter brand: The brand to check.
    /// - Throws: When macOS has no appearance that the check resolves under.
    @MainActor
    @Test(arguments: Brand.allCases)
    func whenSurfaceResolves_shouldTakeBrandHueAtTint(brand: Brand) throws {
        for surface in Surface.allCases {
            for appearance in MacAppearance.allCases {
                let apple = OKLCH(try Self.resolve(surface.apple, in: appearance))
                guard Self.tintableLightness.contains(apple.lightness) else { continue }
                let mine = OKLCH(try Self.resolve(surface.color(of: brand), in: appearance))
                let shown = "\(brand) \(surface.key) \(appearance.label)"
                #expect(
                    abs(mine.chroma - brand.tint) <= Self.chromaTolerance,
                    "\(shown): chroma \(mine.chroma), expected \(brand.tint)",
                )
                #expect(
                    mine.hueDistance(to: brand.hue) <= Self.hueTolerance,
                    "\(shown): hue \(mine.hue), expected \(brand.hue)",
                )
            }
        }
    }

    /// Checks that the fill takes the brand's hue at the brand's lightness, in light and dark.
    ///
    /// - Parameter brand: The brand to check.
    /// - Throws: When macOS has no appearance that the check resolves under.
    @MainActor
    @Test(arguments: Brand.allCases)
    func whenSolidResolves_shouldTakeBrandHueAtSolidLightness(brand: Brand) throws {
        let light = OKLCH(try Self.resolve(NSColor(brand.solid), in: .light))
        let dark = OKLCH(try Self.resolve(NSColor(brand.solid), in: .dark))

        #expect(abs(light.lightness - brand.solidLightness.light) <= Self.roleLightnessTolerance)
        #expect(abs(dark.lightness - brand.solidLightness.dark) <= Self.roleLightnessTolerance)
        #expect(light.hueDistance(to: brand.hue) <= Self.roleHueTolerance)
        #expect(dark.hueDistance(to: brand.hue) <= Self.roleHueTolerance)
    }

    /// Checks that the label on the fill has the brand's lightness, in light and dark.
    ///
    /// - Parameter brand: The brand to check.
    /// - Throws: When macOS has no appearance that the check resolves under.
    @MainActor
    @Test(arguments: Brand.allCases)
    func whenOnSolidResolves_shouldHaveOnSolidLightness(brand: Brand) throws {
        let light = OKLCH(try Self.resolve(NSColor(brand.onSolid), in: .light))
        let dark = OKLCH(try Self.resolve(NSColor(brand.onSolid), in: .dark))

        #expect(abs(light.lightness - brand.onSolidLightness.light) <= Self.roleLightnessTolerance)
        #expect(abs(dark.lightness - brand.onSolidLightness.dark) <= Self.roleLightnessTolerance)
    }

    /// Checks that every role is opaque in every appearance.
    ///
    /// - Parameter brand: The brand to check.
    /// - Throws: When macOS has no appearance that the check resolves under.
    @MainActor
    @Test(arguments: Brand.allCases)
    func whenRoleResolves_shouldBeOpaque(brand: Brand) throws {
        let roles = [brand.text, brand.solid, brand.onSolid, brand.subtle]
        for role in roles {
            for appearance in MacAppearance.allCases {
                let sut = try Self.resolve(NSColor(role), in: appearance)

                #expect(sut.opacity == 1, "\(brand) \(appearance.label) is not opaque")
            }
        }
    }
}

extension Brand {
    /// The lightness of a color in light and in dark appearances.
    fileprivate struct Lightness {
        /// The OKLCH lightness in light mode.
        let light: Double
        /// The OKLCH lightness in dark mode.
        let dark: Double
    }

    /// The lightness the fill has in light and dark.
    fileprivate var solidLightness: Lightness {
        switch self {
        case .swiftLeeds: Lightness(light: 0.72, dark: 0.72)  // swiftlint:disable:this no_magic_numbers - fixture data
        case .kotlinLeeds: Lightness(light: 0.50, dark: 0.60)  // swiftlint:disable:this no_magic_numbers - fixture data
        }
    }

    /// The lightness the label on the fill has in light and dark.
    fileprivate var onSolidLightness: Lightness {
        switch self {
        case .swiftLeeds: Lightness(light: 0.05, dark: 0.05)  // swiftlint:disable:this no_magic_numbers - fixture data
        case .kotlinLeeds: Lightness(light: 0.95, dark: 0.05)  // swiftlint:disable:this no_magic_numbers - fixture data
        }
    }

    /// The chroma this brand gives its surfaces.
    fileprivate var tint: Double {
        switch self {
        case .swiftLeeds: 0.003  // swiftlint:disable:this no_magic_numbers - fixture data
        case .kotlinLeeds: 0.006  // swiftlint:disable:this no_magic_numbers - fixture data
        }
    }

    /// The hue angle this brand gives its surfaces, in degrees.
    fileprivate var hue: Double {
        switch self {
        case .swiftLeeds: 45  // swiftlint:disable:this no_magic_numbers - fixture data
        case .kotlinLeeds: 289  // swiftlint:disable:this no_magic_numbers - fixture data
        }
    }
}
#endif
