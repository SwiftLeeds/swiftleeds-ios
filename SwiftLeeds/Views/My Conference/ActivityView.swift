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
            FancyHeaderView(
                title: activity.title,
                foregroundImageURLs: foregroundImageURLs
            )

            StackedTileView(
                primaryText: activity.subtitle,
                secondaryText: activity.description,
                secondaryColor: Color.primary
            )
            .padding(Padding.screen)
        }
    }

    private var foregroundImageURLs: [URL] {
        if let image = activity.image?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed), let url = URL(string: image) {
            return [url]
        } else {
            return []
        }

    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(activity: .lunch)
    }
}

