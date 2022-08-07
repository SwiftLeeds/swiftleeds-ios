//
//  CommonTileView.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 05/07/2022.
//

import SwiftUI

/// Generic primary secondary view
struct CommonTileView<BackgroundType: ShapeStyle>: View {
    @Environment(\.sizeCategory) var sizeCategory

    let primaryText: String
    let secondaryText: String?
    let primaryColor: Color
    let secondaryColor: Color
    var backgroundStyle: BackgroundType

    var accessibilityTextEnabled: Bool {
        sizeCategory >= .accessibilityMedium
    }

    init(
        primaryText: String,
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
        primaryText: String,
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
        sizeAwareStack(content: {
            Text(primaryText)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(primaryColor)
            if !accessibilityTextEnabled {
                Spacer()
            }
            if let secondaryText = secondaryText {
                Text(secondaryText)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(secondaryColor)
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
                    primaryText: "Primary", secondaryText: "Secondary"
                )
                CommonTileView(
                    primaryText: "Primary", secondaryText: nil
                )
                CommonTileView(
                    primaryText: "Primary",
                    secondaryText: "Secondary",
                    backgroundStyle: .red
                )
                CommonTileView(
                    primaryText: "Primary",
                    secondaryText: "Secondary",
                    primaryColor: .white,
                    secondaryColor: .white.opacity(0.8),
                    backgroundStyle: LinearGradient.weather
                )
            }
            .padding()
        }
    }
}
