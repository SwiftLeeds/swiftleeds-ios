import Foundation
import SwiftUI

extension Notice where Title == Text, Icon == Image, Description == Text {
    /// Creates a notice with a title generated from a localized string.
    ///
    /// - Parameters:
    ///   - titleKey: A title generated from a localized string.
    ///   - icon: The icon that illustrates the condition.
    ///   - description: The text that explains the condition.
    ///   - actions: A content builder that creates the notice's actions.
    public init(
        _ titleKey: LocalizedStringKey,
        icon: UIDesign.Icon,
        description: Text,
        @ViewBuilder actions: () -> Actions,
    ) {
        self.init(
            title: { Text(titleKey) },
            icon: { Image(icon: icon) },
            description: { description },
            actions: actions,
        )
    }

    /// Creates a notice with a title generated from a localized string resource.
    ///
    /// - Parameters:
    ///   - titleResource: The resource for the notice's localized title.
    ///   - icon: The icon that illustrates the condition.
    ///   - description: The text that explains the condition.
    ///   - actions: A content builder that creates the notice's actions.
    @_disfavoredOverload
    public init(
        _ titleResource: LocalizedStringResource,
        icon: UIDesign.Icon,
        description: Text,
        @ViewBuilder actions: () -> Actions,
    ) {
        self.init(
            title: { Text(titleResource) },
            icon: { Image(icon: icon) },
            description: { description },
            actions: actions,
        )
    }

    /// Creates a notice with a title generated from a string.
    ///
    /// The string is not localized, so this is the initializer for text that came from a
    /// server or from a person.
    ///
    /// - Parameters:
    ///   - title: A string used as the notice's title.
    ///   - icon: The icon that illustrates the condition.
    ///   - description: The text that explains the condition.
    ///   - actions: A content builder that creates the notice's actions.
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S,
        icon: UIDesign.Icon,
        description: Text,
        @ViewBuilder actions: () -> Actions,
    ) {
        self.init(
            title: { Text(title) },
            icon: { Image(icon: icon) },
            description: { description },
            actions: actions,
        )
    }
}
