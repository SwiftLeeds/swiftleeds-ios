//
//  HeaderView.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 11/07/2022.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    let imageURL: URL?
    let backgroundURL: URL?

    var placeholderColor: Color = .accentColor
    var imageBackgroundColor: Color = .accentColor

    private let frontImageHeight: CGFloat = 160
    private var imageOffset: CGFloat {
        frontImageHeight/2
    }

    var body: some View {
        ZStack(alignment: .center) {
            backgroundImage
            imageAndTextStack
        }
        .padding(.bottom, imageOffset)
    }

    var imageAndTextStack: some View {
        VStack(spacing: 16) {
            primaryImage
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundColor(.primary)
        }
        .offset(y: imageOffset)
    }

    var primaryImage: some View {
        AsyncImage(
            url: imageURL,
            content: { image in
                Rectangle()
                    .aspectRatio(1.66, contentMode: .fill)
                    .foregroundColor(.clear)
                    .background(
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .transition(.opacity)
                    )
                    .background(imageBackgroundColor)
                    .clipped()
                    .transition(contentTransition)
            },
            placeholder: {
                Rectangle()
                    .foregroundColor(placeholderColor)
                    .transition(contentTransition)
                    .overlay(content: {
                        ProgressView()
                            .tint(.white)
                            .opacity(0.5)
                    })
            }
        )
        .frame(width: frontImageHeight, height: frontImageHeight, alignment: .center)
        .accessibilityHidden(true)
        .cornerRadius(15)
    }

    var backgroundImage: some View {
        AsyncImage(
            url: backgroundURL,
            content: { image in
                Rectangle()
                    .aspectRatio(1.66, contentMode: .fit)
                    .foregroundColor(.clear)
                    .background(
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .transition(.opacity)
                    )
                    .background(imageBackgroundColor)
                    .clipped()
                    .transition(contentTransition)
            },
            placeholder: {
                Rectangle()
                    .foregroundColor(placeholderColor)
                    .transition(contentTransition)
                    .overlay(content: {
                        ProgressView()
                            .tint(.white)
                            .opacity(0.5)
                    })
            }
        )
        .aspectRatio(1.66, contentMode: .fit)
        .edgesIgnoringSafeArea(.top)
        .accessibilityHidden(true)
    }

    private var contentTransition: AnyTransition {
        .opacity.animation(.spring())
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HeaderView(
                title: "Taylor Swift",
                imageURL: URL(string: "https://cdn-az.allevents.in/events5/banners/458482c4fc7489448aa3d77f6e2cd5d0553fa5edd7178dbf18cf986d2172eaf2-rimg-w1200-h675-gmir.jpg?v=1655230338"),
                backgroundURL: URL(string:"https://www.nycgo.com/images/itineraries/42961/soc_fb_dumbo_spots__facebook.jpg")
            )
            Spacer()
        }
    }

    private var contentTransition: AnyTransition {
        .opacity.animation(.spring())
    }
}
