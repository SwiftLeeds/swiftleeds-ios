import SwiftUI

extension EnvironmentValues {
    /// The photo style applied to the view hierarchy.
    @Entry public var photoStyle: any PhotoStyle = .automatic
}

extension View {
    /// Sets the style for photos within this view.
    ///
    /// ```swift
    /// VStack {
    ///     Photo(url: venue.photoURL)
    /// }
    /// .photoStyle(.automatic)
    /// ```
    ///
    /// - Parameter style: The photo style to apply.
    /// - Returns: A view that uses the given style for the photos within it.
    public func photoStyle(_ style: some PhotoStyle) -> some View {
        environment(\.photoStyle, style)
    }
}
