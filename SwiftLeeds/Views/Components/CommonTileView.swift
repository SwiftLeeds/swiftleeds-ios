import DesignKit
import SwiftUI

/// Generic primary secondary view
struct CommonTileView<BackgroundType: ShapeStyle>: View {
    @Environment(\.sizeCategory) var sizeCategory

    let icon: String?
    let primaryText: String
    let secondaryText: String?
    let subtitleText: String?
    let showChevron: Bool
    let primaryColor: Color
    let secondaryColor: Color
    var backgroundStyle: BackgroundType

    var accessibilityTextEnabled: Bool {
        sizeCategory >= .accessibilityMedium
    }

    init(
        icon: String? = nil,
        primaryText: String,
        secondaryText: String? = nil,
        subtitleText: String? = nil,
        showChevron: Bool = false,
        primaryColor: Color = Color.primary,
        secondaryColor: Color = Color.secondary,
        backgroundStyle: BackgroundType
    ) {
        self.icon = icon
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.subtitleText = subtitleText
        self.showChevron = showChevron
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.backgroundStyle = backgroundStyle
    }

    init(
        icon: String? = nil,
        primaryText: String,
        secondaryText: String? = nil,
        subtitleText: String? = nil,
        showChevron: Bool = false,
        primaryColor: Color = Color.primary,
        secondaryColor: Color = Color.secondary,
        backgroundStyle: Color = Color.cellBackground
    ) where BackgroundType == Color {
        self.icon = icon
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.subtitleText = subtitleText
        self.showChevron = showChevron
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.backgroundStyle = backgroundStyle
    }

    var body: some View {
        sizeAwareStack(content: {
            VStack(alignment: .leading, spacing: 2) {
                if let icon {
                    Text("\(Image(systemName: icon)) \(primaryText)")
                        .font(.subheadline.weight(.semibold))
                } else {
                    Text(primaryText)
                        .font(.subheadline.weight(.semibold))
                }


                if let subtitleText {
                    Text(subtitleText)
                        .font(.subheadline.weight(.light))

                }
            }
            .foregroundColor(primaryColor)

            if !accessibilityTextEnabled {
                Spacer()
            }

            if let secondaryText = secondaryText {
                Text(secondaryText)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(secondaryColor)
            } else if showChevron {
                Image(systemName: "chevron.right")
            }
        })
        .padding(Padding.cell)
        .frame(minHeight: Constants.compactCellMinimumHeight)
        .background(
            backgroundStyle,
            in: RoundedRectangle(cornerRadius: Constants.cellRadius)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(primaryText), \(secondaryText ?? "")"
        )
    }

    // When the text is huge, stack vertically instead to avoid compressing the leading text
    @ViewBuilder
    func sizeAwareStack<Content: View>(@ViewBuilder content: () -> (Content)) -> some View {
        if accessibilityTextEnabled {
            VStack {
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            HStack {
                content()
            }
        }
    }
}

struct CommonTileView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).edgesIgnoringSafeArea(.all)
            VStack(spacing: Padding.cellGap) {
                CommonTileView(
                    primaryText: "Primary", secondaryText: "Secondary", subtitleText: "More details", showChevron: true
                )
                CommonTileView(
                    primaryText: "Primary"
                )
                CommonTileView(
                    primaryText: "Primary",
                    secondaryText: "Secondary",
                    backgroundStyle: .red
                )
            }
            .padding()
        }
    }
}
