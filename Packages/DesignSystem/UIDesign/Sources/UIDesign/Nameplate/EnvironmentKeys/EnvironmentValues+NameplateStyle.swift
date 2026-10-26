import SwiftUI

extension EnvironmentValues {
    /// The nameplate style applied to the view hierarchy.
    @Entry public var nameplateStyle: any NameplateStyle = .automatic
}

extension View {
    /// Sets the style for nameplates within this view.
    ///
    /// ```swift
    /// VStack {
    ///     Nameplate(attendee.name, detail: attendee.company) {
    ///         Avatar(url: attendee.photoURL)
    ///     }
    /// }
    /// .nameplateStyle(.prominent)
    /// ```
    ///
    /// - Parameter style: The nameplate style to apply.
    /// - Returns: A view that uses the given style for the nameplates within it.
    public func nameplateStyle(_ style: some NameplateStyle) -> some View {
        environment(\.nameplateStyle, style)
    }
}
