#if canImport(UIKit)
import DesignKit
import SharedAssets
import SwiftUI

/// A small tile with a symbol and a short title that runs an action when tapped.
package struct CompactActionItem: View {
    let icon: String
    let title: String
    let accessibilityHint: String
    let action: () -> Void

    /// Creates the tile.
    ///
    /// - Parameters:
    ///   - icon: The SF Symbol name.
    ///   - title: The title, at most two lines.
    ///   - accessibilityHint: What the tile does, read by VoiceOver.
    ///   - action: Runs when the person taps the tile.
    package init(icon: String, title: String, accessibilityHint: String, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.accessibilityHint = accessibilityHint
        self.action = action
    }

    package var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.accentColor)
                    .frame(height: 32)

                Text(title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                Color.cellBackground,
                in: RoundedRectangle(cornerRadius: Constants.cellRadius)
            )
        }
        .buttonStyle(SquishyButtonStyle())
        .accessibilityHint(accessibilityHint)
    }
}
#endif
