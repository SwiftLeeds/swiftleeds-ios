//
//  SponsorGridView.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 01/07/2022.
//

import SwiftUI

struct SponsorGridView: View {
    let goldSponsors = Sponsor.platinum

    var body: some View {
        VStack(spacing: Padding.cellGap) {
            sectionHeader(text: "Platinum Sponsors")
            contentTile(for: Sponsor.codemagic)
            contentTile(for: Sponsor.stream)
            sectionHeader(text: "Gold Sponsors")
            grid(for: Sponsor.gold)
        }
        .padding()
    }

    private func sectionHeader(text: String) -> some View {
        Text(text)
            .font(.callout.weight(.semibold))
            .foregroundColor(.secondary)
            .frame(maxWidth:.infinity, alignment: .leading)
    }

    private func contentTile(for sponsor: Sponsor, oneLinerEnabled: Bool = true) -> some View {
        ContentTileView(
            title: sponsor.name,
            subTitle: oneLinerEnabled ? sponsor.oneLiner : nil,
            imageURL: sponsor.imageURL,
            imageBackgroundColor: .white,
            imageContentMode: .fit
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
