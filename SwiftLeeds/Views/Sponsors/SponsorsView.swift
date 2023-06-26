//
//  SponsorsView.swift
//  SwiftLeeds
//
//  Created by Muralidharan Kathiresan on 25/06/23.
//

import SwiftUI

struct SponsorsView: View {
    @Environment(\.openURL) var openURL
    @StateObject private var viewModel = SponsorsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: Padding.cellGap) {
                ForEach(viewModel.sponsors, id: \.self) { sponsor in
                    switch sponsor.sponsorLevel {
                    case .silver:
                        sectionHeader(for: .silver)
                        contentTile(for: sponsor)
                    case .gold:
                        sectionHeader(for: .gold)
                        contentTile(for: sponsor)
                    case .platinum:
                        sectionHeader(for: .platinum)
                        contentTile(for: sponsor)
                    }
                }.background(Color.listBackground)
            }
            .accentColor(.white)
            .padding(Padding.cell)
                .task {
                    try? await viewModel.loadSponsors()
                }
        }
    }
}

private extension SponsorsView {
    func sectionHeader(for sponsorLevel: SponsorLevel) -> some View {
        Text("\(sponsorLevel.rawValue.capitalized) Sponsors")
            .font(.callout.weight(.semibold))
            .foregroundColor(.secondary)
            .frame(maxWidth:.infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }

    func contentTile(for sponsor: Sponsor) -> some View {
        ContentTileView(
            accessibilityLabel: "Sponsor",
            title: sponsor.name,
            subTitle: nil,
            imageURL: URL(string: sponsor.image),
            isImagePadded: true,
            imageBackgroundColor: .white,
            imageContentMode: .fit,
            onTap: { openSponsor(sponsor: sponsor) }
        )
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    func openSponsor(sponsor: Sponsor) {
        guard let link = URL(string: sponsor.url) else { return }
        openURL(link)
    }
}

struct SponsorsView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftLeedsContainer {
            ScrollView {
                SponsorsView().padding()
            }
        }
    }
}
