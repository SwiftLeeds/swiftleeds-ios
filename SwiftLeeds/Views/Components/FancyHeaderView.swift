//
//  HeaderView.swift
//  SwiftLeeds
//
//  Created by Kannan Prasad on 05/07/2022.
//

import SwiftUI

struct FancyHeaderView: View {
    let title: String
    let foregroundImageURL: URL
    let backgroundImageURL: URL
    
    private let foregroundImageWidth = 160.0
    private let aspectRatio = 1.66
    
    @State var foregroudGroupViewHeight: CGFloat = .zero
    
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .edgesIgnoringSafeArea(.top)
            .aspectRatio(aspectRatio, contentMode: .fill)
            .background(backgroundImage
                            .aspectRatio(contentMode: .fill))
            .overlay(foregroudGroupView,alignment: .center)
            .padding(.bottom,foregroudGroupViewHeight/2)
    }
    
    private var backgroundImage: some View {
        AsyncImage(url: backgroundImageURL) { phase in
            
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(aspectRatio, contentMode: .fill)
            case .failure(_):
                ProgressView()
                    .tint(.white)
                    .opacity(0.5)
                //TODO: Remove the loaded and set a default image
            @unknown default:
                ProgressView()
                    .tint(.white)
                    .opacity(0.5)
            }
        }
    }
    
    private var foregroudGroupView: some View {
        GeometryReader { geometry in
            VStack{
                foregroundImage
                    .padding(.bottom, Padding.stackGap)
                    .shadow(color: Color.black.opacity(1/3), radius: 8, x: 0, y: 0)
                Text(title)
                    .foregroundColor(.primary)
                    .font(.subheadline.weight(.bold))
                    .padding(.bottom, Padding.stackGap)
                    .accessibilityAddTraits(.isHeader)
            }
            .frame(width: geometry.frame(in: .global).width,
                   height: geometry.frame(in: .global).height)
            .offset(y: geometry.size.height/2)
            .onAppear {
                foregroudGroupViewHeight = geometry.size.height
            }
            .onChange(of: geometry.size) { newValue in
                foregroudGroupViewHeight = newValue.height
            }
        }
    }
    
    private var foregroundImage: some View {
        AsyncImage(url: foregroundImageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success( let image):
                image
                    .resizable()
                    .frame(width: foregroundImageWidth, height: foregroundImageWidth)
                    .cornerRadius(Constants.cellRadius)
                    .accessibilityHidden(true)
            case .failure(_):
                ProgressView()
                    .tint(.white)
                    .opacity(0.5)
                //TODO: Remove the progress view and set a default image
            @unknown default:
                ProgressView()
                    .tint(.white)
                    .opacity(0.5)
            }
        }
    }
}

struct FancyHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        FancyHeaderView(title: "Steve Jobs",
                   foregroundImageURL: URL(string: "https://cdn.profoto.com/cdn/053149e/contentassets/d39349344d004f9b8963df1551f24bf4/profoto-albert-watson-steve-jobs-pinned-image-original.jpg")!,
                   backgroundImageURL: URL(string:"https://offloadmedia.feverup.com/secretldn.com/wp-content/uploads/2018/02/18151550/aviary-rooftop.jpg")!).frame(width: 200, height: 500, alignment: .center)
    }
}
