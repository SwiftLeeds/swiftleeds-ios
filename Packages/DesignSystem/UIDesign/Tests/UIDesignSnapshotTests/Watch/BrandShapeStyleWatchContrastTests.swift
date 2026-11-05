#if os(watchOS)
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite
struct BrandShapeStyleWatchContrastTests {
    /// The largest difference allowed in one component.
    private static let tolerance: Float = 0.001

    @Test(arguments: Brand.allCases)
    func whenContrastIsStandard_shouldResolveToDarkValue(brand: Brand) throws {
        let expected = try ColorSet(named: Self.secondarySurfaceName(of: brand)).color(for: .dark)

        let difference = Self.largestDifference(of: brand, under: .standard, from: expected)

        #expect(difference <= Self.tolerance, "\(brand) differs by \(difference)")
    }

    @Test(arguments: Brand.allCases)
    func whenContrastIsIncreased_shouldResolveToIncreasedContrastValue(brand: Brand) throws {
        let expected = try ColorSet(named: Self.secondarySurfaceName(of: brand)).color(for: .darkIncreasedContrast)

        let difference = Self.largestDifference(of: brand, under: .increased, from: expected)

        #expect(difference <= Self.tolerance, "\(brand) differs by \(difference)")
    }

    /// Returns the name of the color set that holds a brand's secondary surface.
    ///
    /// - Parameter brand: The brand the color belongs to.
    /// - Returns: The set's name, such as `swiftLeeds-secondarySurface`.
    private static func secondarySurfaceName(of brand: Brand) -> ColorSet.Name {
        ColorSet.Name("\(brand)-secondarySurface")
    }

    /// Returns the largest difference in one component between the secondary surface style and a value.
    ///
    /// - Parameters:
    ///   - brand: The brand to set in the environment.
    ///   - contrast: The contrast to resolve under, in dark mode.
    ///   - expected: The value to compare with.
    /// - Returns: The largest absolute difference across red, green, blue and opacity.
    private static func largestDifference(
        of brand: Brand,
        under contrast: ColorSchemeContrast,
        from expected: Color.Resolved,
    ) -> Float {
        var environment = EnvironmentValues()
        environment.colorScheme = .dark
        environment._colorSchemeContrast = contrast
        environment.brand = brand
        let style: BrandShapeStyle = .secondarySurface
        return style.resolve(in: environment).resolve(in: environment).largestDifference(from: expected)
    }
}
#endif
