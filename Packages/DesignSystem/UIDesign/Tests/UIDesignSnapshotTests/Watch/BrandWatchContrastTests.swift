#if os(watchOS)
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite
struct BrandWatchContrastTests {
    /// One color of one brand, with the catalog set that holds its values.
    struct RoleCase: CustomTestStringConvertible, Sendable {
        /// The set that holds the color's values.
        let setName: ColorSet.Name

        /// Reads the brand color under test.
        let color: @Sendable (Brand) -> Color

        /// The brand the color belongs to.
        let brand: Brand

        /// The set's name, which labels the case in a failure.
        var testDescription: String { setName.description }

        /// Creates a case for a brand color.
        ///
        /// - Parameters:
        ///   - brand: The brand the color belongs to.
        ///   - setName: The set that holds the color's values.
        ///   - color: The brand's property that returns the color.
        init(_ brand: Brand, setName: ColorSet.Name, color: @escaping @Sendable (Brand) -> Color) {
            self.brand = brand
            self.setName = setName
            self.color = color
        }
    }

    /// The largest difference allowed in one component.
    private static let tolerance: Float = 0.001

    /// Every color of every brand.
    nonisolated static var cases: [RoleCase] {
        Brand.allCases.flatMap { brand in
            [
                RoleCase(brand, setName: ColorSet.Name("\(brand)-surface"), color: \.surface),
                RoleCase(brand, setName: ColorSet.Name("\(brand)-secondarySurface"), color: \.secondarySurface),
                RoleCase(brand, setName: ColorSet.Name("\(brand)-tertiarySurface"), color: \.tertiarySurface),
                RoleCase(brand, setName: ColorSet.Name("\(brand)-groupedSurface"), color: \.groupedSurface),
                RoleCase(
                    brand,
                    setName: ColorSet.Name("\(brand)-secondaryGroupedSurface"),
                    color: \.secondaryGroupedSurface,
                ),
                RoleCase(
                    brand,
                    setName: ColorSet.Name("\(brand)-tertiaryGroupedSurface"),
                    color: \.tertiaryGroupedSurface,
                ),
                RoleCase(brand, setName: ColorSet.Name("\(brand)-text"), color: \.text),
                RoleCase(brand, setName: ColorSet.Name("\(brand)-solid"), color: \.solid),
                RoleCase(brand, setName: ColorSet.Name("\(brand)-onSolid"), color: \.onSolid),
                RoleCase(brand, setName: ColorSet.Name("\(brand)-subtle"), color: \.subtle),
            ]
        }
    }

    @Test(arguments: cases)
    func whenContrastIsStandard_shouldResolveToDarkValue(role: RoleCase) throws {
        let expected = try ColorSet(named: role.setName).color(for: .dark)

        let difference = Self.largestDifference(of: role, under: .standard, from: expected)

        #expect(difference <= Self.tolerance, "\(role.setName) differs by \(difference)")
    }

    @Test(arguments: cases)
    func whenContrastIsIncreased_shouldResolveToIncreasedContrastValue(role: RoleCase) throws {
        let expected = try ColorSet(named: role.setName).color(for: .darkIncreasedContrast)

        let difference = Self.largestDifference(of: role, under: .increased, from: expected)

        #expect(difference <= Self.tolerance, "\(role.setName) differs by \(difference)")
    }

    /// Returns the largest difference in one component between a brand color and a value.
    ///
    /// - Parameters:
    ///   - role: The brand color to resolve.
    ///   - contrast: The contrast to resolve it under, in dark mode.
    ///   - expected: The value to compare with.
    /// - Returns: The largest absolute difference across red, green, blue and opacity.
    private static func largestDifference(
        of role: RoleCase,
        under contrast: ColorSchemeContrast,
        from expected: Color.Resolved,
    ) -> Float {
        var environment = EnvironmentValues()
        environment.colorScheme = .dark
        environment._colorSchemeContrast = contrast
        return role.color(role.brand).resolve(in: environment).largestDifference(from: expected)
    }
}
#endif
