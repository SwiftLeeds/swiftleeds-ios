#if DEBUG
import SwiftUI

struct SpecimenGroup<Content: View>: View {
    private let title: String
    @ViewBuilder private let content: () -> Content

    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .small) {
            Text(title)
                .font(.headline)
            Grid(
                alignment: .leading,
                horizontalSpacing: CGFloat(Spacing.medium),
                verticalSpacing: CGFloat(Spacing.small)
            ) {
                content()
            }
            .font(.caption)
        }
    }
}

// Sample size for a token that is not itself a width or a height.
enum Sample {
    static let width: CGFloat = 64
    static let height: CGFloat = 32
}
#endif
