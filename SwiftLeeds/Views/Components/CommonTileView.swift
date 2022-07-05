//
//  CommonTileView.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 05/07/2022.
//

import SwiftUI

/// Generic primary secondary view
struct CommonTileView<BackgroundType: ShapeStyle>: View {
    let primaryText: String
    let secondaryText: String?
    let primaryColor: Color
    let secondaryColor: Color
    var backgroundStyle: BackgroundType

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
        HStack(alignment: .center) {
            Text(primaryText)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(primaryColor)
            Spacer()
            if let secondaryText = secondaryText {
                Text(secondaryText)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(secondaryColor)
            }
        }
        .padding(Padding.cell)
        .frame(minHeight: Constants.compactCellMinimumHeight)
        .background(
            backgroundStyle,
            in: RoundedRectangle(cornerRadius: Constants.cellRadius)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(primaryText) \(secondaryText ?? "")"
        )
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
                    backgroundStyle:
                        LinearGradient.init(
                            colors: [.weatherGradientStart, .weatherGradientStart],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                )
            }
            .padding()
        }
    }
}
