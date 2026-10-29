#if DEBUG
import SwiftUI

/// A titled table of tokens, one to a row.
struct SpecimenGroup<Content: View>: View {
    private let title: String
    @ViewBuilder private let content: () -> Content

    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .sm) {
            Text(title)
                .font(.headline)
            Grid(
                alignment: .leading,
                horizontalSpacing: .md,
                verticalSpacing: .sm,
            ) {
                content()
            }
            .font(.caption)
        }
    }
}
#endif
