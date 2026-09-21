#if canImport(UIKit)
import SwiftUI

package struct SectionHeader: View {
    private let title: String
    private let fontStyle: Font
    private let foregroundColor: Color
    private let maxWidth: CGFloat
    private let alignment: Alignment
    private let accessibilityTraits: AccessibilityTraits

    package init(
        title: String,
        fontStyle: Font = .callout.weight(.semibold),
        foregroundColor: Color = .secondary,
        maxWidth: CGFloat = .infinity,
        alignment: Alignment = .leading,
        accessibilityTraits: AccessibilityTraits = .isHeader
    ) {
        self.title = title
        self.fontStyle = fontStyle
        self.foregroundColor = foregroundColor
        self.maxWidth = maxWidth
        self.alignment = alignment
        self.accessibilityTraits = accessibilityTraits
    }

    package var body: some View {
        Text(title)
            .font(fontStyle)
            .foregroundColor(foregroundColor)
            .frame(maxWidth: maxWidth, alignment: alignment)
            .accessibilityAddTraits(accessibilityTraits)
    }
}

struct SectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeader(title: "SwiftLeeds")
    }
}
#endif
