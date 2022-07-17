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

    @State private var textImageStackSize = CGSize.zero

    private let backgroundImageWidthToHeightRatio: CGFloat = 1.66
    private let frontImageHeight: CGFloat = 160
    private var imageOffset: CGFloat {
        frontImageHeight/2
    }

    var body: some View {
        VStack(alignment: .center) {
            backgroundImage
                .overlay(
                    imageAndTextStack.measureSize { size in
                        textImageStackSize = size
                    },
                    alignment: .center
                )
        }
        .padding(.bottom, textImageStackSize.height/2)
    }

    var text: some View {
        VStack(spacing: Padding.cellGap) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
    }

    var imageAndTextStack: some View {
        VStack(spacing: Padding.cellGap) {
            frontImage
            text
        }
        .offset(x: 0, y: textImageStackSize.height/2)
    }

    var frontImage: some View {
        AsyncImage(
            url: imageURL,
            content: { image in
                Rectangle()
                    .aspectRatio(backgroundImageWidthToHeightRatio, contentMode: .fill)
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
        .cornerRadius(Constants.cellRadius)
        .shadow(color: Color.black.opacity(1/3), radius: 8, x: 0, y: 0)
    }

    var backgroundImage: some View {
        AsyncImage(
            url: backgroundURL,
            content: { image in
                Rectangle()
                    .aspectRatio(backgroundImageWidthToHeightRatio, contentMode: .fit)
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
        .aspectRatio(backgroundImageWidthToHeightRatio, contentMode: .fit)
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
            Text("hey! :)")
        }
    }

    private var contentTransition: AnyTransition {
        .opacity.animation(.spring())
    }
}
