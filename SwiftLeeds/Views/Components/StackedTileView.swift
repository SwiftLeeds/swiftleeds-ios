//
//  StackedTileView.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 05/07/2022.
//

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
            if let primaryText = primaryText {
                Text(primaryText)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(primaryColor)
            }

            if let secondaryText = secondaryText {
                Text(.init(secondaryText))
                    .font(.subheadline.weight(.regular))
                    .foregroundColor(secondaryColor)
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
        [primaryText?.noEmojis, secondaryText?.noEmojis].compactMap { $0 }.joined(separator: ", ")
    }
}


struct StackedTileView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).edgesIgnoringSafeArea(.all)
            VStack(spacing: Padding.cellGap) {
                StackedTileView(
                    primaryText: "Primary", secondaryText: "Walkin' through a crowd, the village is aglow\nKaleidoscope of loud heartbeats under coats\nEverybody here wanted somethin' more\nSearchin' for a sound we hadn't heard before"
                )
                StackedTileView(
                    primaryText: "Primary",
                    secondaryText: "And it said\nWelcome to New York, it's been waitin' for you\nWelcome to New York, welcome to New York",
                    primaryColor: .white,
                    secondaryColor: .white,
                    backgroundStyle: .red
                )
                StackedTileView(
                    primaryText: "Primary",
                    secondaryText: "Like any great love, it keeps you guessing\nLike any real love, it's ever-changing\nLike any true love, it drives you crazy\nBut you know you wouldn't change anything, anything, anything",
                    primaryColor: .white,
                    secondaryColor: .white.opacity(0.8),
                    backgroundStyle: LinearGradient(colors: [.blue, .teal], startPoint: .leading, endPoint: .trailing)
                )
            }
            .padding()
        }
    }
}
