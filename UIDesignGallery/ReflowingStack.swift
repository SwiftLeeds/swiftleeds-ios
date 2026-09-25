import SwiftUI
import UIDesign

/// A view that lays its content out along the axis the text size asks for.
///
/// At an accessibility size the parts stack, which gives the text the whole
/// width instead of the share a leading symbol leaves it. This is one view
/// hierarchy rather than two, so the parts keep their identity across the
/// switch and nothing animates in or out when the text size changes.
///
/// ```swift
/// ReflowingStack {
///     Image(systemName: resource.symbol)
///     Text(resource.title)
/// }
/// ```
struct ReflowingStack<Content: View>: View {
    /// How large this person has asked text to be.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// How the parts line up across the row, while they are still a row.
    ///
    /// It applies to the horizontal arrangement only. The stacked arrangement
    /// always aligns to the leading edge.
    var alignment: VerticalAlignment = .center

    /// A content builder that creates the parts this view lays out.
    @ViewBuilder let content: Content

    /// The arrangement this text size asks for.
    private var layout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: CGFloat(Spacing.small)))
            : AnyLayout(HStackLayout(alignment: alignment, spacing: CGFloat(Spacing.medium)))
    }

    var body: some View {
        layout {
            content
        }
    }
}
