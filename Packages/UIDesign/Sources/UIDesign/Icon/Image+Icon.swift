import SwiftUI

public extension Image {
    /// Creates an image of an icon.
    ///
    /// The result is an ordinary image, so every symbol modifier applies to it:
    ///
    /// ```swift
    /// Image(icon: .live)
    ///     .symbolRenderingMode(.palette)
    ///     .foregroundStyle(.error, .secondarySurface)
    ///     .symbolEffect(.pulse)
    /// ```
    ///
    /// The image has no accessibility label. Add one with `accessibilityLabel(_:)`, or use
    /// ``SwiftUI/Label/init(_:icon:)`` instead.
    ///
    /// - Parameter icon: The icon to draw.
    init(icon: Icon) {
        self.init(systemName: String(icon))
    }

    /// Creates an image of an icon, filled to a value.
    ///
    /// A symbol with no variable form ignores the value.
    ///
    /// - Parameters:
    ///   - icon: The icon to draw.
    ///   - variableValue: How full the symbol is, from `0` to `1`.
    init(icon: Icon, variableValue: Double?) {
        self.init(systemName: String(icon), variableValue: variableValue)
    }
}

public extension Label where Title == Text, Icon == Image {
    /// Creates a label with an icon beside its title.
    ///
    /// The title doubles as the accessibility label, so prefer this over a bare image.
    ///
    /// - Parameters:
    ///   - title: The title, looked up for translation.
    ///   - icon: The icon to draw beside it.
    init(_ title: LocalizedStringKey, icon: UIDesign.Icon) {
        self.init {
            Text(title)
        } icon: {
            Image(icon: icon)
        }
    }
}
