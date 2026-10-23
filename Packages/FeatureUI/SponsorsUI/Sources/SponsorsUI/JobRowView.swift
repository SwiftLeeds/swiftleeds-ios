import SponsorsFeature
import SwiftUI
import UIAssets

/// A row that shows a job's title and location, and opens its page when tapped.
struct JobRowView: View {
    /// The job the row shows.
    let job: Job

    /// The action that opens the job's web address.
    @Environment(\.openURL) private var openURL

    /// A Boolean that indicates whether the user is pressing the row.
    @State private var isPressed = false

    /// A button that shows the job's title and location, and presses in while held.
    var body: some View {
        Button(
            action: {
                if let url = job.url {
                    openURL(url)
                }
            },
            label: {
                VStack(spacing: 0) {
                    Divider()

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(job.title)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.primary)
                                .lineLimit(1)

                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.caption2)
                                    .accessibilityHidden(true)
                                Text(job.location)
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "arrow.right.circle")
                            .font(.title3)
                            .foregroundColor(.accent.opacity(0.5))
                            .accessibilityHidden(true)
                    }
                    .padding()
                    .background(isPressed ? Color.accent.opacity(0.05) : Color.clear)
                }
            },
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .onLongPressGesture(
            minimumDuration: 0.1, maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = pressing
                }
            }, perform: {},
        )
    }
}
