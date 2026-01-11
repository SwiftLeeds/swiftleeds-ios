import SwiftUI

struct SectionHeader: View {
    private let title: String
    private let fontStyle: Font
    private let foregroundColor: Color
    private let maxWidth: CGFloat
    private let alignment: Alignment
    private let accesibilityAddTraits: AccessibilityTraits

    init(
        title: String,
        fontStyle: Font = .callout.weight(.semibold),
        foregroundColor : Color = .secondary,
        maxWidth: CGFloat = .infinity,
        alignment: Alignment = .leading,
        accessbilityAddTraits: AccessibilityTraits = .isHeader
    ) {
        self.title = title
        self.fontStyle = fontStyle
        self.foregroundColor = foregroundColor
        self.maxWidth = maxWidth
        self.alignment = alignment
        self.accesibilityAddTraits = accessbilityAddTraits
    }
    
    var body: some View {
        Text(title)
            .font(fontStyle)
            .foregroundColor(foregroundColor)
            .frame(maxWidth: maxWidth, alignment: alignment)
            .accessibilityAddTraits(accesibilityAddTraits)
    }
}

struct SectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeader(title: "SwiftLeeds")
    }
}
