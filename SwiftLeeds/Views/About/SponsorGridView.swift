//
//  SponsorGridView.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 01/07/2022.
//

import SwiftUI

struct SponsorGridView: View {
    @Environment(\.openURL) var openURL

    var body: some View {
        VStack(spacing: Padding.cellGap) {
            sectionHeader(text: "Platinum Sponsors")
            ForEach(Sponsor.platinum, id: \.self) { sponsor in
                contentTile(for: sponsor)
            }
            sectionHeader(text: "Gold Sponsors")
            grid(for: Sponsor.gold)
        }
    }

    private func sectionHeader(text: String) -> some View {
        Text(text)
            .font(.callout.weight(.semibold))
            .foregroundColor(.secondary)
            .frame(maxWidth:.infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }

    private func contentTile(for sponsor: Sponsor, oneLinerEnabled: Bool = true) -> some View {
        ContentTileView(
            accessibilityLabel: "Sponsor",
            title: sponsor.name,
            subTitle: oneLinerEnabled ? sponsor.oneLiner : nil,
            imageURL: sponsor.imageURL,
            imageBackgroundColor: .white,
            imageContentMode: .fit,
            onTap: { openSponsor(sponsor: sponsor) }
        )
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func grid(for sponsors: [Sponsor]) -> some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: Padding.cellGap), count: 2),
            alignment: .center, spacing: Padding.cellGap, pinnedViews: []) {
                ForEach(sponsors, id: \.self) { sponsor in
                    contentTile(for: sponsor, oneLinerEnabled: false)
                }
        }
    }

    private func openSponsor(sponsor: Sponsor) {
        guard let link = sponsor.link else { return }
        openURL(link)
    }
}

struct SponsorGridView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftLeedsContainer {
            ScrollView {
                SponsorGridView()
            }
        }
    }
}
