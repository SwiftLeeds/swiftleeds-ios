import DesignKit
import SharedAssets
import SwiftUI

/// Used when there's lots of content to display.
struct StackedTileView<BackgroundType: ShapeStyle>: View {
    let primaryText: String?
    let secondaryText: String?
    let primaryColor: Color
    let secondaryColor: Color
    var backgroundStyle: BackgroundType

    init(
        primaryText: String?,
        secondaryText: String?,
        primaryColor: Color = Color.primary,
        secondaryColor: Color = Color.secondary,
        backgroundStyle: BackgroundType
    ) {
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.backgroundStyle = backgroundStyle
    }

    init(
        primaryText: String?,
        secondaryText: String?,
        primaryColor: Color = Color.primary,
        secondaryColor: Color = Color.secondary,
        backgroundStyle: Color = Color.cellBackground
    ) where BackgroundType == Color {
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.backgroundStyle = backgroundStyle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Padding.stackGap) {
            if let primaryText = primaryText, primaryText.isEmpty == false {
                Text(primaryText)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(primaryColor)
            }

            if let secondaryText = secondaryText, secondaryText.isEmpty == false {
                Text(.init(secondaryText))
                    .font(.subheadline.weight(.regular))
                    .accentColor(.accent)
            }
        }
        .frame(maxWidth: .infinity, minHeight: Constants.compactCellMinimumHeight, alignment: .leading)
        .multilineTextAlignment(.leading)
        .padding(Padding.cell)
        .background(
            backgroundStyle,
            in: RoundedRectangle(cornerRadius: Constants.cellRadius)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        [primaryText?.noEmojis, secondaryText?.noEmojis]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
struct StackedTileView_Previews: PreviewProvider {
    private static let longBody = """
    A stacked tile carries a headline and a body that can run to several paragraphs. \
    This filler stands in for a talk synopsis, which is the longest thing the tile \
    has to lay out.

    A second paragraph checks that a line break survives the layout, and that the \
    tile grows to fit its text rather than truncating it.
    """

    private static let gradient = LinearGradient(
        colors: [.blue, .teal],
        startPoint: .leading,
        endPoint: .trailing
    )

    static var previews: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).edgesIgnoringSafeArea(.all)
            VStack(spacing: Padding.cellGap) {
                StackedTileView(primaryText: "Primary", secondaryText: longBody)
                StackedTileView(
                    primaryText: "Primary",
                    secondaryText: longBody,
                    primaryColor: .white,
                    secondaryColor: .white,
                    backgroundStyle: .red
                )
                StackedTileView(
                    primaryText: "Primary",
                    secondaryText: longBody,
                    primaryColor: .white,
                    secondaryColor: .white.opacity(0.8),
                    backgroundStyle: gradient
                )
            }
            .padding()
        }
    }
}
