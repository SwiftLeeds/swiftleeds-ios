import SwiftUI

extension Badge where Label == SwiftUI.Label<Text, Image> {
    /// Creates a badge that generates its label from a localized string key and an icon.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the badge's localized title, which is its word.
    ///   - icon: The icon to draw beside the title.
    public init(_ titleKey: LocalizedStringKey, icon: Icon) {
        self.init {
            SwiftUI.Label {
                Text(titleKey)
            } icon: {
                Image(icon: icon)
            }
        }
    }

    /// Creates a badge that generates its label from a localized string resource and an icon.
    ///
    /// - Parameters:
    ///   - titleResource: The resource for the badge's localized title, which is its word.
    ///   - icon: The icon to draw beside the title.
    @_disfavoredOverload
    public init(_ titleResource: LocalizedStringResource, icon: Icon) {
        self.init {
            SwiftUI.Label {
                Text(titleResource)
            } icon: {
                Image(icon: icon)
            }
        }
    }

    /// Creates a badge that generates its label from a string and an icon.
    ///
    /// The string is not localized, so this is the initializer for text that came from a
    /// server or from a person.
    ///
    /// - Parameters:
    ///   - title: A string used as the badge's title, which is its word.
    ///   - icon: The icon to draw beside the title.
    @_disfavoredOverload
    public init<S: StringProtocol>(_ title: S, icon: Icon) {
        self.init {
            SwiftUI.Label {
                Text(title)
            } icon: {
                Image(icon: icon)
            }
        }
    }

    /// Creates a badge that generates its label from a localized string key and a status.
    ///
    /// The badge draws the status's icon and colors, and ignores the palette.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the badge's localized title, which is its word.
    ///   - status: The status the badge marks.
    public init(_ titleKey: LocalizedStringKey, status: BadgeStatus) {
        self.init(status: status) {
            SwiftUI.Label {
                Text(titleKey)
            } icon: {
                Image(icon: status.icon)
            }
        }
    }

    /// Creates a badge that generates its label from a localized string resource and a status.
    ///
    /// The badge draws the status's icon and colors, and ignores the palette.
    ///
    /// - Parameters:
    ///   - titleResource: The resource for the badge's localized title, which is its word.
    ///   - status: The status the badge marks.
    @_disfavoredOverload
    public init(_ titleResource: LocalizedStringResource, status: BadgeStatus) {
        self.init(status: status) {
            SwiftUI.Label {
                Text(titleResource)
            } icon: {
                Image(icon: status.icon)
            }
        }
    }

    /// Creates a badge that generates its label from a string and a status.
    ///
    /// The string is not localized, so this is the initializer for text that came from a
    /// server or from a person. The badge draws the status's icon and colors, and ignores the
    /// palette.
    ///
    /// - Parameters:
    ///   - title: A string used as the badge's title, which is its word.
    ///   - status: The status the badge marks.
    @_disfavoredOverload
    public init<S: StringProtocol>(_ title: S, status: BadgeStatus) {
        self.init(status: status) {
            SwiftUI.Label {
                Text(title)
            } icon: {
                Image(icon: status.icon)
            }
        }
    }
}
