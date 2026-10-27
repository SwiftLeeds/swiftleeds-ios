import SwiftUI

extension EnvironmentValues {
    /// The brand that views in this environment draw: SwiftLeeds unless an ancestor sets another.
    @Entry public var brand: Brand = .swiftLeeds
}
