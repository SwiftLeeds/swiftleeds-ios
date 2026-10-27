import SwiftUI

extension ShapeStyle {
    /// Returns the components this style draws with in an environment, or `nil` when it resolves
    /// to something other than a color.
    ///
    /// A style resolves to a color, which then resolves to its components, or straight to the
    /// components when it is a color already.
    ///
    /// - Parameter environment: The environment to resolve in.
    /// - Returns: The components, or `nil` for a style that is not a color.
    func components(in environment: EnvironmentValues) -> Color.Resolved? {
        let resolved = resolve(in: environment)
        if let color = resolved as? Color {
            return color.resolve(in: environment)
        }
        return resolved as? Color.Resolved
    }
}
