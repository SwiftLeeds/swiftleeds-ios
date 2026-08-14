import SwiftUI

package struct NameplatePlaceholder: View {
    package init() {}

    package var body: some View {
        Nameplate(
            Text(verbatim: "──────────"),
            detail: Text(verbatim: "────────────")
        ) {
            Avatar(url: nil) {
                EmptyView()
            }
        }
        .redacted(reason: .placeholder)
        .accessibilityLabel("Loading")
    }
}
