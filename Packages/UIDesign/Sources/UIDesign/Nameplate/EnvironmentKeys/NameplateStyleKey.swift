import SwiftUI

extension EnvironmentValues {
    /// How every ``Nameplate`` below this point draws.
    @Entry public var nameplateStyle: any NameplateStyle = .automatic
}

public extension View {
    /// Sets how every ``Nameplate`` in this view draws.
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
    /// - Parameter style: How to draw each nameplate.
    func nameplateStyle(_ style: some NameplateStyle) -> some View {
        environment(\.nameplateStyle, style)
    }
}
