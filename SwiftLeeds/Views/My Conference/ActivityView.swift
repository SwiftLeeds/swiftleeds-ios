//
//  ActivityView.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 06/08/2022.
//

import SwiftUI

struct ActivityView: View {
    let activity: Activity

    @Environment(\.openURL) var openURL

    var body: some View {
        SwiftLeedsContainer {
            ScrollView {
                content
            }
        }
        .edgesIgnoringSafeArea(.top)
    }

    private var content: some View {
        VStack(spacing: Padding.stackGap) {
            HeaderView(
                title: activity.title,
                imageURL: URL(string: activity.image ?? ""),
                backgroundImageAssetName: Assets.Image.playhouseImage
            )

            StackedTileView(
                primaryText: activity.subtitle,
                secondaryText: activity.description,
                secondaryColor: Color.primary
            )
            .padding(Padding.screen)
        }
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(activity: .lunch)
    }
}

