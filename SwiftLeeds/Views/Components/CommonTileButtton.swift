//
//  CommonTileButtton.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 05/07/2022.
//

import SwiftUI

struct CommonTileButtton<BackgroundType: ShapeStyle>: View {
    let primaryText: String
    let secondaryText: String?
    let primaryColor: Color
    let secondaryColor: Color
    var backgroundStyle: BackgroundType

    let onTap: () -> ()

    init(
        primaryText: String,
        secondaryText: String?,
        primaryColor: Color = Color.primary,
        secondaryColor: Color = Color.secondary,
        backgroundStyle: Color = Color.cellBackground,
        onTap: @escaping () -> ()
    ) where BackgroundType == Color {
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.backgroundStyle = backgroundStyle
        self.onTap = onTap
    }

    init(
        primaryText: String,
        secondaryText: String?,
        primaryColor: Color = Color.primary,
        secondaryColor: Color = Color.secondary,
        backgroundStyle: BackgroundType,
        onTap: @escaping () -> ()
    ) {
        self.primaryText = primaryText
        self.secondaryText = secondaryText
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
                CommonTileButtton(
                    primaryText: "Primary",
                    secondaryText: "Secondary",
                    onTap: {}
                )
                CommonTileButtton(
                    primaryText: "Primary",
                    secondaryText: nil,
                    onTap: {}
                )
                CommonTileButtton(
                    primaryText: "Primary",
                    secondaryText: "Secondary",
                    backgroundStyle: .red,
                    onTap: {}
                )
                CommonTileButtton(
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
