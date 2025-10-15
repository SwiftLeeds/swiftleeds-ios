//
//  CommonTileButton.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 05/07/2022.
//

import SwiftUI

struct CommonTileButton<BackgroundType: ShapeStyle>: View {
    let icon: String?
    let primaryText: String
    let secondaryText: String?
    let subtitleText: String?
    let accessibilityHint: String?
    let showChevron: Bool
    let primaryColor: Color
    let secondaryColor: Color
    var backgroundStyle: BackgroundType

    let onTap: () -> ()

    init(
        icon: String? = nil,
        primaryText: String,
        secondaryText: String? = nil,
        subtitleText: String? = nil,
        accessibilityHint: String? = nil,
        showChevron: Bool = false,
        primaryColor: Color = Color.primary,
        secondaryColor: Color = Color.secondary,
        backgroundStyle: Color = Color.cellBackground,
        onTap: @escaping () -> ()
    ) where BackgroundType == Color {
        self.icon = icon
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.subtitleText = subtitleText
        self.accessibilityHint = accessibilityHint
        self.showChevron = showChevron
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.backgroundStyle = backgroundStyle
        self.onTap = onTap
    }

    init(
        icon: String? = nil,
        primaryText: String,
        secondaryText: String? = nil,
        subtitleText: String? = nil,
        accessibilityHint: String? = nil,
        showChevron: Bool = false,
        primaryColor: Color = Color.primary,
        secondaryColor: Color = Color.secondary,
        backgroundStyle: BackgroundType,
        onTap: @escaping () -> ()
    ) {
        self.icon = icon
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.subtitleText = subtitleText
        self.accessibilityHint = accessibilityHint
        self.showChevron = showChevron
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.backgroundStyle = backgroundStyle
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            CommonTileView(
                icon: icon,
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
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits(.isButton)
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
