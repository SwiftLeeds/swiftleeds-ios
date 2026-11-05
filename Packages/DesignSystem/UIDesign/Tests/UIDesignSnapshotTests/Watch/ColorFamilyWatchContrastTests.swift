#if os(watchOS)
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite
struct ColorFamilyWatchContrastTests {
    /// One color of one family, with the catalog set that holds its values.
    struct RoleCase: CustomTestStringConvertible, Sendable {
        /// The set that holds the color's values.
        let setName: ColorSet.Name

        /// Reads the family color under test.
        let color: @Sendable (ColorFamily) -> Color

        /// The family the color belongs to.
        let family: ColorFamily

        /// The set's name, which labels the case in a failure.
        var testDescription: String { setName.description }

        /// Creates a case for a family color.
        ///
        /// - Parameters:
        ///   - family: The family the color belongs to.
        ///   - setName: The set that holds the color's values.
        ///   - color: The family's property that returns the color.
        init(_ family: ColorFamily, setName: ColorSet.Name, color: @escaping @Sendable (ColorFamily) -> Color) {
            self.family = family
            self.setName = setName
            self.color = color
        }
    }

    /// The largest difference allowed in one component, as the catalog stores four decimal places.
    private static let tolerance: Float = 0.001

    /// Every color of every family.
    nonisolated static var cases: [RoleCase] {
        ColorFamily.allCases.flatMap { family in
            [
                RoleCase(family, setName: ColorSet.Name("\(family)-text"), color: \.text),
                RoleCase(family, setName: ColorSet.Name("\(family)-solid"), color: \.solid),
                RoleCase(family, setName: ColorSet.Name("\(family)-onSolid"), color: \.onSolid),
                RoleCase(family, setName: ColorSet.Name("\(family)-subtle"), color: \.subtle),
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

    /// Returns the largest difference in one component between a family color and a value.
    ///
    /// - Parameters:
    ///   - role: The family color to resolve.
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
        let actual = role.color(role.family).resolve(in: environment)
        return [
            abs(actual.red - expected.red),
            abs(actual.green - expected.green),
            abs(actual.blue - expected.blue),
            abs(actual.opacity - expected.opacity),
        ].max() ?? .infinity
    }
}
#endif
