//
//  CommonTileButton.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 05/07/2022.
//

import SwiftUI

struct CommonTileButton<BackgroundType: ShapeStyle>: View {
    let primaryText: String
    let secondaryText: String?
    let subtitleText: String?
    let showChevron: Bool
    let primaryColor: Color
    let secondaryColor: Color
    var backgroundStyle: BackgroundType

    let onTap: () -> ()

    init(
        primaryText: String,
        secondaryText: String? = nil,
        subtitleText: String? = nil,
        showChevron: Bool = false,
        primaryColor: Color = Color.primary,
        secondaryColor: Color = Color.secondary,
        backgroundStyle: Color = Color.cellBackground,
        onTap: @escaping () -> ()
    ) where BackgroundType == Color {
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.subtitleText = subtitleText
        self.showChevron = showChevron
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.backgroundStyle = backgroundStyle
        self.onTap = onTap
    }

    init(
        primaryText: String,
        secondaryText: String?,
        subtitleText: String? = nil,
        showChevron: Bool = false,
        primaryColor: Color = Color.primary,
        secondaryColor: Color = Color.secondary,
        backgroundStyle: BackgroundType,
        onTap: @escaping () -> ()
    ) {
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.subtitleText = subtitleText
        self.showChevron = showChevron
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.backgroundStyle = backgroundStyle
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            CommonTileView(
                primaryText: primaryText,
                secondaryText: secondaryText,
                subtitleText: subtitleText,
                showChevron: showChevron,
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
                backgroundStyle: backgroundStyle
            )
        }
        .buttonStyle(SquishyButtonStyle())
    }
}

struct CommonTileButtton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).edgesIgnoringSafeArea(.all)
            VStack(spacing: Padding.cellGap) {
                CommonTileButton(
                    primaryText: "Primary",
                    secondaryText: "Secondary",
                    onTap: {}
                )
                CommonTileButton(
                    primaryText: "Primary",
                    showChevron: true,
                    onTap: {}
                )
                CommonTileButton(
                    primaryText: "Primary",
                    secondaryText: "Secondary",
                    backgroundStyle: .red,
                    onTap: {}
                )
                CommonTileButton(
                    primaryText: "Primary",
                    secondaryText: "Secondary",
                    primaryColor: .white,
                    secondaryColor: .white.opacity(0.8),
                    backgroundStyle: LinearGradient.weather,
                    onTap: {}
                )
            }
            .padding()
        }
    }
}
