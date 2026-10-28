import Foundation
import SwiftUI
import Testing
import UIDesign

#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

/// Tests that the surfaces keep Apple's lightness and carry a hint of the brand in the environment.
///
/// A surface keeps the OKLCH lightness of Apple's background for this platform and takes the brand
/// hue at a faint, fixed chroma: 0.003 for SwiftLeeds, 0.006 for KotlinLeeds. Black and white cannot
/// hold a chroma, so the tint is checked only where Apple's color can carry one.
@MainActor
struct SurfaceColorTests {
    /// A surface token beside the Apple color whose lightness it keeps.
    private enum Surface: CaseIterable {
        /// The main background of an interface.
        case surface

        /// The background of content layered on top of the main background.
        case secondarySurface

        /// The background of content layered on top of secondary backgrounds.
        case tertiarySurface

        /// The main background of a grouped interface.
        case groupedSurface

        /// The background of content layered on top of the main background of a grouped interface.
        case secondaryGroupedSurface

        /// The background of content layered on top of secondary backgrounds of a grouped interface.
        case tertiaryGroupedSurface

        #if canImport(AppKit)
        /// Apple's color for this surface on macOS.
        ///
        /// macOS has no grouped backgrounds, so a grouped surface copies its plain counterpart.
        var appleColor: NSColor {
            switch self {
            case .surface: .windowBackgroundColor

            case .secondarySurface: .controlBackgroundColor

            case .tertiarySurface: .underPageBackgroundColor

            case .groupedSurface: .windowBackgroundColor

            case .secondaryGroupedSurface: .controlBackgroundColor

            case .tertiaryGroupedSurface: .underPageBackgroundColor
            }
        }
        #else
        /// Apple's color for this surface on iOS.
        var appleColor: UIColor {
            switch self {
            case .surface: .systemBackground

            case .secondarySurface: .secondarySystemBackground

            case .tertiarySurface: .tertiarySystemBackground

            case .groupedSurface: .systemGroupedBackground

            case .secondaryGroupedSurface: .secondarySystemGroupedBackground

            case .tertiaryGroupedSurface: .tertiarySystemGroupedBackground
            }
        }
        #endif

        /// Returns the token resolved in an environment, in OKLCH.
        ///
        /// - Parameter environment: The environment to resolve it in.
        /// - Returns: The resolved color, or `nil` for a token that is not a color.
        @MainActor
        func resolve(in environment: EnvironmentValues) -> OKLCH? {
            switch self {
            case .surface: SurfaceColorTests.resolve(.surface, in: environment)

            case .secondarySurface: SurfaceColorTests.resolve(.secondarySurface, in: environment)

            case .tertiarySurface: SurfaceColorTests.resolve(.tertiarySurface, in: environment)

            case .groupedSurface: SurfaceColorTests.resolve(.groupedSurface, in: environment)

            case .secondaryGroupedSurface:
                SurfaceColorTests.resolve(.secondaryGroupedSurface, in: environment)

            case .tertiaryGroupedSurface:
                SurfaceColorTests.resolve(.tertiaryGroupedSurface, in: environment)
            }
        }
    }

    /// The hue of the SwiftLeeds brand, in OKLCH degrees.
    private static let swiftLeedsHue: Double = 45

    /// The hue of the KotlinLeeds brand, in OKLCH degrees.
    private static let kotlinLeedsHue: Double = 289

    /// The OKLCH chroma of a SwiftLeeds surface, a warm gray rather than a visible orange.
    private static let swiftLeedsTint: Double = 0.003

    /// The OKLCH chroma of a KotlinLeeds surface.
    private static let kotlinLeedsTint: Double = 0.006

    /// The lightness an Apple color must have for a tint to show: not black, not white.
    private static let tintableLightness: ClosedRange<Double> = 0.05...0.98

    /// How far a surface's lightness may sit from Apple's, after the catalog rounds it.
    private static let lightnessTolerance: Double = 0.003

    /// How far a resolved chroma may sit from the tint, after the catalog rounds it.
    private static let chromaTolerance: Double = 0.0005

    /// How far a faint color's hue may sit from the brand hue, in degrees.
    ///
    /// At a chroma this low, the catalog's rounding moves the angle by a few degrees.
    private static let hueTolerance: Double = 6

    #if canImport(AppKit)
    /// The major version of macOS that the catalog's Mac surfaces were sampled on.
    nonisolated private static let sampledMacOSMajorVersion = 27
    #endif

    /// Whether this platform runs the OS version the catalog sampled, or a later one.
    ///
    /// It is always `true` on iOS.
    nonisolated private static let runsOnSampledOSOrLater: Bool = {
        #if canImport(AppKit)
        ProcessInfo.processInfo.isOperatingSystemAtLeast(
            OperatingSystemVersion(majorVersion: sampledMacOSMajorVersion, minorVersion: 0, patchVersion: 0)
        )
        #else
        true
        #endif
    }()

    /// Returns an environment that carries a brand and a color scheme.
    ///
    /// - Parameters:
    ///   - brand: The brand views in the environment draw.
    ///   - colorScheme: The color scheme of the environment.
    /// - Returns: The environment.
    private static func environment(for brand: Brand, in colorScheme: ColorScheme) -> EnvironmentValues {
        var environment = EnvironmentValues()
        environment.brand = brand
        environment.colorScheme = colorScheme
        return environment
    }

    /// Returns a token resolved in an environment, in OKLCH.
    ///
    /// - Parameters:
    ///   - style: The token to resolve.
    ///   - environment: The environment to resolve it in.
    /// - Returns: The resolved color as lightness, chroma and hue, or `nil` for a token that is not
    ///   a color.
    private static func resolve(_ style: some ShapeStyle, in environment: EnvironmentValues) -> OKLCH? {
        style.components(in: environment).map(OKLCH.init)
    }

    /// Returns Apple's color for a surface under a color scheme, in OKLCH.
    ///
    /// On macOS the color is fixed under the matching appearance, on iOS under the matching traits.
    ///
    /// - Parameters:
    ///   - surface: The surface whose Apple color to read.
    ///   - colorScheme: The color scheme to fix it under.
    /// - Returns: Apple's color as lightness, chroma and hue.
    /// - Throws: When the platform has no appearance or no sRGB form for the color.
    private static func apple(for surface: Surface, in colorScheme: ColorScheme) throws -> OKLCH {
        #if canImport(AppKit)
        let name: NSAppearance.Name = colorScheme == .dark ? .darkAqua : .aqua
        let appearance = try #require(NSAppearance(named: name))
        var fixed: NSColor?
        appearance.performAsCurrentDrawingAppearance {
            fixed = surface.appleColor.usingColorSpace(.sRGB)
        }
        let color = try #require(fixed)
        return OKLCH(Color(nsColor: color).resolve(in: EnvironmentValues()))
        #else
        let traits = UITraitCollection { $0.userInterfaceStyle = colorScheme == .dark ? .dark : .light }
        let fixed = surface.appleColor.resolvedColor(with: traits)
        return OKLCH(Color(uiColor: fixed).resolve(in: EnvironmentValues()))
        #endif
    }

    /// Returns the hue a brand tints its surfaces with.
    ///
    /// - Parameter brand: The brand to read.
    /// - Returns: The hue, in OKLCH degrees.
    private static func hue(of brand: Brand) -> Double {
        switch brand {
        case .swiftLeeds: swiftLeedsHue

        case .kotlinLeeds: kotlinLeedsHue
        }
    }

    /// Returns the chroma a brand tints its surfaces with.
    ///
    /// - Parameter brand: The brand to read.
    /// - Returns: The OKLCH chroma.
    private static func tint(of brand: Brand) -> Double {
        switch brand {
        case .swiftLeeds: swiftLeedsTint

        case .kotlinLeeds: kotlinLeedsTint
        }
    }

    /// Checks that every surface keeps the lightness of Apple's color, for every brand.
    ///
    /// - Parameters:
    ///   - brand: The brand in the environment.
    ///   - colorScheme: The color scheme to resolve in.
    /// - Throws: When the platform has no appearance or no sRGB form for a color.
    @Test(
        .enabled(if: Self.runsOnSampledOSOrLater, "The surfaces were sampled on a later OS version"),
        arguments: Brand.allCases,
        [ColorScheme.light, .dark],
    )
    func whenSurfaceResolves_shouldKeepAppleLightness(brand: Brand, colorScheme: ColorScheme) throws {
        let environment = Self.environment(for: brand, in: colorScheme)
        for surface in Surface.allCases {
            let apple = try Self.apple(for: surface, in: colorScheme)
            let resolved = try #require(surface.resolve(in: environment))
            #expect(
                abs(resolved.lightness - apple.lightness) <= Self.lightnessTolerance,
                "\(surface) lightness \(resolved.lightness) for \(brand) in \(colorScheme), Apple's \(apple.lightness)",
            )
        }
    }

    /// Checks that every surface that can hold a chroma takes the brand hue at the brand's tint.
    ///
    /// - Parameters:
    ///   - brand: The brand in the environment.
    ///   - colorScheme: The color scheme to resolve in.
    /// - Throws: When the platform has no appearance or no sRGB form for a color.
    @Test(arguments: Brand.allCases, [ColorScheme.light, .dark])
    func whenSurfaceResolves_shouldCarryBrandTint(brand: Brand, colorScheme: ColorScheme) throws {
        let environment = Self.environment(for: brand, in: colorScheme)
        let hue = Self.hue(of: brand)
        let tint = Self.tint(of: brand)
        for surface in Surface.allCases {
            let apple = try Self.apple(for: surface, in: colorScheme)
            guard Self.tintableLightness.contains(apple.lightness) else { continue }
            let resolved = try #require(surface.resolve(in: environment))
            #expect(
                abs(resolved.chroma - tint) <= Self.chromaTolerance,
                "\(surface) chroma \(resolved.chroma) for \(brand) in \(colorScheme), expected \(tint)",
            )
            #expect(
                abs(resolved.hue - hue) <= Self.hueTolerance,
                "\(surface) hue \(resolved.hue) for \(brand) in \(colorScheme), expected \(hue)",
            )
        }
    }
}
