import SwiftUI

/// A shape style that draws one of the brand's colors, read from the environment.
///
/// The brand is the value of ``SwiftUI/EnvironmentValues/brand``. A view that sets another brand
/// redraws every token in it, so a call site such as `.background(.surface)` needs no change.
public struct BrandShapeStyle: ShapeStyle {
    /// A job a color does for the brand.
    enum Role {
        /// The fill that marks something as ours.
        case brand

        /// The label on the brand fill.
        case onBrand

        /// The background of a screen.
        case surface

        /// The background of grouped content on a screen.
        case secondarySurface

        /// The background of an element inside grouped content.
        case tertiarySurface
    }

    /// The job this style's color does.
    private let role: Role

    /// Creates a style that draws the color for a role.
    ///
    /// - Parameter role: The job the color does.
    init(role: Role) {
        self.role = role
    }

    /// Evaluates to a resolved shape style given the current environment.
    ///
    /// - Parameter environment: The environment to read the brand from.
    /// - Returns: The color the brand in `environment` has for this style's role.
    public func resolve(in environment: EnvironmentValues) -> Color {
        let brand = environment.brand
        return switch role {
        case .brand: brand.solid

        case .onBrand: brand.onSolid

        case .surface: brand.surface

        case .secondarySurface: brand.secondarySurface

        case .tertiarySurface: brand.tertiarySurface
        }
    }
}
