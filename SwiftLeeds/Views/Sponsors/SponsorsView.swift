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
                if section.type != .silver {
                    Section(header: sectionHeader(for: section.type)) {
                        ForEach(section.sponsors) { sponsor in
                            contentTile(for: sponsor)
                        }
                    }
                } else {
                    Section(header: sectionHeader(for: section.type)) {
                        grid(for: section.sponsors)
                        .background(Color.listBackground)
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
    }
    
    func openSponsor(sponsor: Sponsor) {
        guard let link = URL(string: sponsor.url) else { return }
        openURL(link)
    }
    
    func grid(for sponsors: [Sponsor]) -> some View {
        let adaptiveColumns = [
            GridItem(.adaptive(minimum: 170))
        ]
        let numberOfColumns = [
            GridItem(.flexible()), GridItem(.flexible())
        ]

        return LazyVGrid(
            columns: numberOfColumns,
            alignment: .leading,
            spacing: Padding.cellGap,
            pinnedViews: []) {
                ForEach(sponsors, id: \.self) { sponsor in
                    ZStack {
                        contentTile(for: sponsor)
                    }
                }
            }
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
