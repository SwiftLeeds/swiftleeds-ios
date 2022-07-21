//
//  ContributorsPage.swift
//  SwiftLeeds
//
//  Created by LUCKY AGARWAL on 20/07/22.
//

import SwiftUI

struct ContributorsView: View {
    var body: some View {
        SwiftLeedsContainer {
            ScrollView {
                content
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    private func sectionHeader(text: String) -> some View {
        Text(text)
            .font(.callout.weight(.semibold))
            .foregroundColor(.secondary)
            .frame(maxWidth:.infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
    
    private var content: some View {
        VStack(spacing: Padding.stackGap) {
            HeaderView(
                title: "Our Team",
                imageAssetName: Assets.Image.swiftLeedsIcon,
                backgroundImageAssetName: Assets.Image.playhouseImage
            )
            Group {
                StackedTileView(primaryText: "About", secondaryText: Strings.aboutContributor)
                sectionHeader(text: "Contributors")
                grid(for: Contributor.contributors)
            }
            .padding(Padding.screen)
        }
    }
    
    private func contentTile(for contributer: Contributor, oneLinerEnabled: Bool = true) -> some View {
        ContentTileView(
            accessibilityLabel: "Contributor",
            title: contributer.name,
            subTitle: oneLinerEnabled ? contributer.oneLiner : nil,
            imageURL: contributer.imageURL,
            imageBackgroundColor: .white,
            imageContentMode: .fill,
            onTap: { }
        )
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    
    private func grid(for contributors: [Contributor]) -> some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: Padding.cellGap), count: 2),
            alignment: .center, spacing: Padding.cellGap, pinnedViews: []) {
                ForEach(contributors, id: \.self) { contributor in
                    contentTile(for: contributor, oneLinerEnabled: false)
                }
            }
    }
}
struct ContributorsPage_Previews: PreviewProvider {
    static var previews: some View {
        ContributorsView()
    }
}
