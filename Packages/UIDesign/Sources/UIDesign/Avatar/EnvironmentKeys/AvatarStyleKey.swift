import SwiftUI

extension EnvironmentValues {
    /// How every ``Avatar`` below this point draws.
    @Entry public var avatarStyle: any AvatarStyle = .automatic
}

public extension View {
    /// Sets how every ``Avatar`` in this view draws.
    ///
    /// ```swift
    /// VStack {
    ///     Avatar(url: first.photoURL)
    ///     Avatar(url: second.photoURL)
    /// }
    /// .avatarStyle(.rounded)
    /// ```
    func avatarStyle(_ style: some AvatarStyle) -> some View {
        environment(\.avatarStyle, style)
    }
}
