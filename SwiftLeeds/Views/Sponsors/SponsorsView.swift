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
        List {
            ForEach(viewModel.sections) { section in
                Section(header: Text(section.id)){
                    ForEach(section.sponsors) { sponsor in
                        contentTile(for: sponsor)
                    }
                }
            }
        }
        .task {
            try? await viewModel.loadSponsors()
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
