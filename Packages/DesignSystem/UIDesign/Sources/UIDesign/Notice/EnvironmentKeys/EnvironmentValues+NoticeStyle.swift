import SwiftUI

extension EnvironmentValues {
    /// The notice style applied to the view hierarchy.
    @Entry public var noticeStyle: any NoticeStyle = .automatic
}

extension View {
    /// Sets the style for notices within this view.
    ///
    /// ```swift
    /// List {
    ///     Section {
    ///         Notice("You're offline", icon: Icon(.wifiSlash), description: Text("...")) {
    ///             Button("Try Again") { reload() }.buttonStyle(.borderless)
    ///         }
    ///     }
    /// }
    /// .noticeStyle(.automatic)
    /// ```
    ///
    /// - Parameter style: The notice style to apply.
    /// - Returns: A view that uses the given style for the notices within it.
    public func noticeStyle(_ style: some NoticeStyle) -> some View {
        environment(\.noticeStyle, style)
    }
}
