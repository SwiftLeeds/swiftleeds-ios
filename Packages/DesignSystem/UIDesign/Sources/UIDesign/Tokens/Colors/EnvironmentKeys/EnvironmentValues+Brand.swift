import SwiftUI

extension EnvironmentValues {
    /// The brand that views in this environment draw: SwiftLeeds unless an ancestor sets another.
    @Entry package var brand: Brand = .swiftLeeds
}
