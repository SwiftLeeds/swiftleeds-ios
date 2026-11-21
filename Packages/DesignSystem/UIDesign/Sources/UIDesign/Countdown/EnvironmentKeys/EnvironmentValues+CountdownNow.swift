import SwiftUI

extension EnvironmentValues {
    /// The moment that countdowns in this environment count from.
    @Entry package var countdownNow: CountdownNow = .live
}

extension View {
    /// Sets the moment that countdowns within this view count from.
    ///
    /// - Parameter now: The moment to count from.
    /// - Returns: A view whose countdowns count from `now`.
    package func countdownNow(_ now: CountdownNow) -> some View {
        environment(\.countdownNow, now)
    }
}
