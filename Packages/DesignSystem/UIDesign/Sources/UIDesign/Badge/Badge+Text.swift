import Foundation
import SwiftUI

extension Badge where Label == Text {
    /// Creates a badge with a title generated from a localized string.
    ///
    /// - Parameter titleKey: The key for the badge's localized title.
    public init(_ titleKey: LocalizedStringKey) {
        self.init { Text(titleKey) }
    }

    /// Creates a badge with a title generated from a localized string resource.
    ///
    /// - Parameter titleResource: The resource for the badge's localized title.
    @_disfavoredOverload
    public init(_ titleResource: LocalizedStringResource) {
        self.init { Text(titleResource) }
    }

    /// Creates a badge with a title generated from a string.
    ///
    /// The string is not localized, so this is the initializer for text that came from a
    /// server or from a person.
    ///
    /// - Parameter title: A string used as the badge's title.
    @_disfavoredOverload
    public init<S: StringProtocol>(_ title: S) {
        self.init { Text(title) }
    }
}
