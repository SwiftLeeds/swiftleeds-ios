import SwiftUI

extension EnvironmentValues {
    /// The nameplate style applied to the view hierarchy.
    @Entry public var nameplateStyle: any NameplateStyle = .automatic
}

public extension View {
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
    func nameplateStyle(_ style: some NameplateStyle) -> some View {
        environment(\.nameplateStyle, style)
    }
}
