#if os(iOS)
import Foundation
import SwiftUI
import Testing
import UIDesign
import UIKit

/// Tests that each ``Brand`` surface keeps Apple's lightness on iOS and takes the brand's hue.
@MainActor
struct BrandSurfaceTests {
    /// A surface a brand tints, paired with the Apple color it copies the lightness of.
    private enum Surface: CaseIterable {
        /// The color for the main background of an interface.
        case surface
        /// The color for content layered on top of the main background.
        case secondarySurface
        /// The color for content layered on top of secondary backgrounds.
        case tertiarySurface

        /// The key the generator's `APPLE_SURFACES` table uses for this surface.
        var key: String {
            switch self {
            case .surface: "surface"
            case .secondarySurface: "secondarySurface"
            case .tertiarySurface: "tertiarySurface"
            }
        }

        /// The Apple color this surface copies the lightness of.
        var apple: UIColor {
            switch self {
            case .surface: .systemBackground
            case .secondarySurface: .secondarySystemBackground
            case .tertiarySurface: .tertiarySystemBackground
            }
        }

        /// Returns the brand's color for this surface.
        ///
        /// - Parameter brand: The brand to read.
        /// - Returns: The brand's tinted surface.
        func color(of brand: Brand) -> UIColor {
            switch self {
            case .surface: UIColor(brand.surface)
            case .secondarySurface: UIColor(brand.secondarySurface)
            case .tertiarySurface: UIColor(brand.tertiarySurface)
            }
        }
    }

    /// How far a surface's lightness may sit from Apple's.
    private static let lightnessTolerance = 0.003
    /// How far a surface's chroma may sit from the brand's tint.
    private static let chromaTolerance = 0.0005
    /// How far a surface's hue may sit from the brand's hue, in degrees.
    private static let hueTolerance = 6.0
    /// The lightness range in which a color is neither too dark nor too light to hold a tint.
    private static let tintableLightness = 0.05...0.98
    /// The largest value of one color component in a hex code.
    private static let hexScale: Float = 255

    /// The appearances at the base level, in the generator's order: light, dark, then each with
    /// Increase Contrast.
    private static let baseAppearances = SystemAppearance.allCases.filter { !$0.isElevated }

    /// The appearances in an elevated container, in the same order as ``baseAppearances``.
    private static let elevatedAppearances = SystemAppearance.allCases.filter(\.isElevated)

    /// Every appearance a surface is checked under: the base level, then the elevated level.
    private static let appearances = baseAppearances + elevatedAppearances

    /// Returns the components a color has under an appearance.
    ///
    /// - Parameters:
    ///   - color: The color to resolve.
    ///   - appearance: The appearance to resolve it under.
    /// - Returns: The color as fixed components.
    private static func resolve(_ color: UIColor, in appearance: SystemAppearance) -> Color.Resolved {
        // Fixed with the traits first: `EnvironmentValues` cannot set Increase Contrast.
        Color(color.resolvedColor(with: appearance.traits)).resolve(in: EnvironmentValues())
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
    /// - Returns: One line per surface and level, ready to paste as its `universal` or `elevated` entry.
    private static func appleSurfaceReport() -> String {
        let keys = [("universal", baseAppearances), ("elevated", elevatedAppearances)]
        let lines = Surface.allCases.flatMap { surface in
            keys.map { key, levelAppearances in
                let codes = levelAppearances.map { "\"\(hex(of: resolve(surface.apple, in: $0)))\"" }
                return "        \"\(key)\": (\(codes.joined(separator: ", "))),  # \(surface.key)"
            }
        }
        let order = baseAppearances.map(\.name).joined(separator: ", ")
        return "Apple's iOS surfaces (\(order), then the same four elevated):\n" + lines.joined(separator: "\n")
    }

    /// Checks that each surface keeps the lightness Apple's matching color has, and is opaque.
    ///
    /// - Parameter brand: The brand to check.
    @Test(arguments: Brand.allCases)
    func whenSurfaceResolves_shouldKeepAppleLightness(brand: Brand) {
        var drifted: [String] = []
        for surface in Surface.allCases {
            for appearance in Self.appearances {
                let mine = Self.resolve(surface.color(of: brand), in: appearance)
                let apple = Self.resolve(surface.apple, in: appearance)
                let gap = abs(OKLCH(mine).lightness - OKLCH(apple).lightness)
                if gap > Self.lightnessTolerance || mine.opacity != 1 {
                    drifted.append("\(surface.key) \(appearance.name)")
                }
            }
        }
        #expect(drifted.isEmpty, "\(brand) drifted from Apple in \(drifted). \(Self.appleSurfaceReport())")
    }

    /// Checks that each surface Apple leaves room to tint takes the brand's hue and chroma.
    ///
    /// - Parameter brand: The brand to check.
    @Test(arguments: Brand.allCases)
    func whenSurfaceResolves_shouldTakeBrandHueAtTint(brand: Brand) {
        for surface in Surface.allCases {
            for appearance in Self.appearances {
                let apple = OKLCH(Self.resolve(surface.apple, in: appearance))
                guard Self.tintableLightness.contains(apple.lightness) else { continue }
                let mine = OKLCH(Self.resolve(surface.color(of: brand), in: appearance))
                let shown = "\(brand) \(surface.key) \(appearance.name)"
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

    /// Checks that a dark surface in an elevated container is lighter than at the base level.
    ///
    /// - Parameter brand: The brand to check.
    @Test(arguments: Brand.allCases)
    func whenLevelIsElevated_shouldLiftDarkSurface(brand: Brand) {
        let base = OKLCH(Self.resolve(UIColor(brand.surface), in: .dark))
        let elevated = OKLCH(Self.resolve(UIColor(brand.surface), in: .darkElevated))
        #expect(
            elevated.lightness > base.lightness,
            "\(brand) surface: elevated lightness \(elevated.lightness), base \(base.lightness)",
        )
    }
}

extension Brand {
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
