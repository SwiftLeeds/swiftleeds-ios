//
//  StackedTileView.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 05/07/2022.
//

import SwiftUI

/// Used when there's lots of content to display.
struct StackedTileView<BackgroundType: ShapeStyle>: View {
    let primaryText: String
    let secondaryText: String
    let primaryColor: Color
    let secondaryColor: Color
    var backgroundStyle: BackgroundType

    init(
        primaryText: String,
        secondaryText: String,
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
        secondaryText: String,
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
            Text(primaryText)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(primaryColor)
            Text(secondaryText)
                .font(.subheadline.weight(.medium))
                .foregroundColor(secondaryColor)
        }
        .frame(maxWidth: .infinity, minHeight: Constants.compactCellMinimumHeight, alignment: .leading)
        .multilineTextAlignment(.leading)
        .padding(Padding.cell)
        .background(
            backgroundStyle,
            in: RoundedRectangle(cornerRadius: Constants.cellRadius)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(primaryText + " " + secondaryText)
    }
}


struct StackedTileView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).edgesIgnoringSafeArea(.all)
            VStack(spacing: Padding.cellGap) {
                StackedTileView(
                    primaryText: "Primary", secondaryText: "Secondary"
                )
                StackedTileView(
                    primaryText: "Primary",
                    secondaryText: "Secondary",
                    backgroundStyle: .red
                )
                StackedTileView(
                    primaryText: "Primary",
                    secondaryText: "Secondary",
                    primaryColor: .white,
                    secondaryColor: .white.opacity(0.8),
                    backgroundStyle: LinearGradient(colors: [.blue, .teal], startPoint: .leading, endPoint: .trailing)
                )
            }
            .padding()
        }
    }
}
