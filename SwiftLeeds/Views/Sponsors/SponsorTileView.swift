//
//  SponsorTileView.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 01/07/2022.
//

import SwiftUI
import CachedAsyncImage

struct SponsorTileView: View {
    let sponsor: Sponsor

    @Environment(\.openURL) private var openURL

    var body: some View {
        Button(action: { openURL(sponsor.url) }) {
            VStack(alignment: .leading, spacing: 0) {
                image
                    .padding(16)

                text

                if sponsor.jobs.isEmpty == false {
                    Text("JOBS")
                        .font(.caption)
                        .fontWeight(.thin)
                        .padding(Padding.cell)
                }

                ForEach(sponsor.jobs) { job in
                    VStack(spacing: 0) {
                        Divider()
                        CommonTileButton(primaryText: job.title,
                                         showChevron: true,
                                         backgroundStyle: Color.cellBackground) {
                            openURL(job.url)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
        .background(Color.cellBackground, in: contentShape)
        .buttonStyle(SquishyButtonStyle())
    }

    private var image: some View {
        CachedAsyncImage(
            url: URL(string: sponsor.image),
            content: { image in
                Rectangle()
                    .aspectRatio(1.66, contentMode: .fill)
                    .foregroundColor(.clear)
                    .background(
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .transition(.opacity)
                    )
                    .background(Color.cellBackground)
                    .clipped()
                    .transition(contentTransition)
            },
            placeholder: {
                Rectangle()
                    .foregroundColor(.cellBackground)
                    .transition(contentTransition)
                    .overlay(content: {
                        ProgressView()
                            .tint(.white)
                            .opacity(0.5)
                    })
            }
        )
        .aspectRatio(1.66, contentMode: .fit)
        .accessibilityHidden(true)
    }

    private var text: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(sponsor.name)
                .foregroundColor(.primary)
                .font(.subheadline.weight(.medium))

            if sponsor.subtitle.isEmpty == false {
                Text(sponsor.subtitle)
                    .foregroundColor(.secondary)
                    .font(.subheadline.weight(.regular))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Sponsor, \(sponsor.name), \(sponsor.subtitle)"
        )
        .padding()
        .frame(minHeight: 55)
    }

    private var contentShape: some Shape {
        RoundedRectangle(cornerRadius: Constants.cellRadius, style: .continuous)
    }

    private var contentTransition: AnyTransition {
        .opacity.animation(.spring())
    }

    private func openURL(_ urlString: String) {
        guard let link = URL(string: urlString) else { return }
        openURL(link)
    }
}

struct SponsorTileView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)

            VStack {
                SponsorTileView(
                    sponsor: .sample
                )
            }
            .padding()
        }
    }
}
