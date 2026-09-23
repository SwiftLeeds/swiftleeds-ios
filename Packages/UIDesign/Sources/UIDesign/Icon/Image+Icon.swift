import SwiftUI

public extension Image {
    /// Creates an image of the icon.
    ///
    /// The result is a plain `Image`, so every symbol modifier still applies:
    ///
    /// ```swift
    /// Image(icon: .live)
    ///     .symbolRenderingMode(.palette)
    ///     .foregroundStyle(.error, .secondarySurface)
    ///     .symbolEffect(.pulse)
    /// ```
    ///
    /// It carries no accessibility label. Add one, or use `Label(_:icon:)`.
    ///
    /// - Parameter icon: The icon to draw.
    init(icon: Icon) {
        self.init(systemName: String(icon))
    }

    /// Creates an image of the icon, filled to a value.
    ///
    /// Use this for a symbol that shows a level, such as signal strength or volume. A symbol with
    /// no variable form ignores the value.
    ///
    /// - Parameters:
    ///   - icon: The icon to draw.
    ///   - variableValue: How full the symbol is, from 0 to 1.
    init(icon: Icon, variableValue: Double?) {
        self.init(systemName: String(icon), variableValue: variableValue)
    }
}

public extension Label where Title == Text, Icon == Image {
    /// Creates a label with the icon beside its title.
    ///
    /// The title is the accessibility label, so prefer this over a bare image.
    ///
    /// - Parameters:
    ///   - title: The text to show, looked up for translation.
    ///   - icon: The icon to draw beside it.
    init(_ title: LocalizedStringKey, icon: UIDesign.Icon) {
        self.init {
            Text(title)
        } icon: {
            Image(icon: icon)
        }
    }
}
