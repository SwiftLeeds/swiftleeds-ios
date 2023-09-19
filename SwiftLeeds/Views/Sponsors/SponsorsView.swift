//
//  SponsorsView.swift
//  SwiftLeeds
//
//  Created by Muralidharan Kathiresan on 25/06/23.
//

import SwiftUI
import ReadabilityModifier

struct SponsorsView: View {
    @StateObject private var viewModel = SponsorsViewModel()
    
    var body: some View {
        SwiftLeedsContainer {
            content
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    private var content: some View {
        List {
            ForEach(viewModel.sections) { section in
                switch section.type {
                case .platinum:
                    Section(header: sectionHeader(for: section.type)) {
                        ForEach(section.sponsors) { sponsor in
                            sponsorTile(for: sponsor)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets())
                                .padding(.bottom, Padding.cellGap   )
                        }
                    }
                case .gold, .silver:
                    Section(header: sectionHeader(for: section.type)) {
                        grid(for: section.sponsors)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                    }
                }
            }
        }
        .padding(.top, 50)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .fitToReadableContentGuide(type: .width)
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
            .textCase(nil)
            .padding(.bottom, 8)
    }
    
    func sponsorTile(for sponsor: Sponsor) -> some View {
        SponsorTileView(sponsor: sponsor)
    }
    
    func grid(for sponsors: [Sponsor]) -> some View {
        let columns = [
            GridItem(.flexible()), GridItem(.flexible())
        ]

        return LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: Padding.cellGap,
            pinnedViews: []) {
                ForEach(sponsors, id: \.self) { sponsor in
                    sponsorTile(for: sponsor)
                }
            }.foregroundColor(.clear)
    }
}

struct SponsorsView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftLeedsContainer {
            ScrollView {
                SponsorsView()
            }
        }
    }
}
