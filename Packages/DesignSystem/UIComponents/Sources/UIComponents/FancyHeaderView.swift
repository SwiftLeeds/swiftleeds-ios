import Foundation
import SwiftUI
import UIAssets

/// A screen header: a venue photograph, images overlapping its lower edge, and a title.
public struct FancyHeaderView: View {
    private let title: String
    private let foregroundImageURLs: [URL]
    private let foregroundImage: Image?

    private let foregroundImageWidth: Double = 160
    private let aspectRatio = 1.66

    @State private var foregroundGroupViewHeight: CGFloat = .zero

    public init(title: String, foregroundImageURLs: [URL] = [], foregroundImage: Image? = nil) {
        self.title = title
        self.foregroundImageURLs = foregroundImageURLs
        self.foregroundImage = foregroundImage
    }

    public var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .edgesIgnoringSafeArea(.top)
            .aspectRatio(aspectRatio, contentMode: .fill)
            .background(
                createRectangleImage(for: Image.leedsPlayhouse, aspectRatio: aspectRatio)
                    .scaledToFill()
                    .accessibilityHidden(true)
            )
            .overlay(foregroundGroup, alignment: .center)
            .padding(.bottom, foregroundGroupViewHeight / 2)
    }

    private var foregroundGroup: some View {
        GeometryReader { geometry in
            VStack(spacing: Padding.cellGap) {
                foregroundImages
                    .frame(width: foregroundImageWidth * Double(foregroundImageCount))
                    .cornerRadius(Constants.cellRadius)
                    .shadow(color: shadowColor, radius: 8, x: 0, y: 0)
                Text(title)
                    .foregroundColor(.primary)
                    .font(.title3.weight(.bold))
                    .accessibilityAddTraits(.isHeader)
            }
            .frame(
                width: geometry.frame(in: .global).width,
                height: geometry.frame(in: .global).height,
            )
            .offset(y: geometry.size.height / 2)
            .onAppear {
                foregroundGroupViewHeight = geometry.size.height
            }
            .onChange(of: geometry.size) { _, newValue in
                foregroundGroupViewHeight = newValue.height
            }
        }
    }

    @ViewBuilder
    private var foregroundImages: some View {
        if !foregroundImageURLs.isEmpty {
            HStack {
                ForEach(foregroundImageURLs, id: \.self) { foregroundImageURL in
                    AsyncImage(url: foregroundImageURL) { phase in
                        switch phase {
                        case .empty:
                            loadingView()

                        case .success(let image):
                            createRectangleImage(for: image)
                                .accessibilityHidden(true)

                        case .failure:
                            createRectangleImage(for: Image.swiftLeedsIcon)

                        @unknown default:
                            loadingView()
                        }
                    }
                }
            }
        } else if let foregroundImage {
            createRectangleImage(for: foregroundImage)
        } else {
            createRectangleImage(for: Image.swiftLeedsIcon)
        }
    }

    /// The number of foreground images, counting the placeholder as one when there are none.
    private var foregroundImageCount: Int {
        let count = foregroundImageURLs.count + (foregroundImage == nil ? 0 : 1)
        return count == 0 ? 1 : count
    }

    /// The color of the shadow behind the foreground images.
    private var shadowColor: Color {
        Color.black.opacity(1 / 3)
    }

    private func createRectangleImage(for image: Image, aspectRatio: Double = 1.0) -> some View {
        Rectangle()
            .foregroundColor(.clear)
            .aspectRatio(aspectRatio, contentMode: .fit)
            .background(
                image
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            )
    }

    private func loadingView(aspectRatio: Double = 1.0) -> some View {
        Rectangle()
            .foregroundColor(.secondary)
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay(
                ProgressView()
            )
            .progressViewStyle(CircularProgressViewStyle())
    }
}

#if DEBUG
#Preview("Stacked") {
    VStack {
        Text(verbatim: "Local Asset")
        FancyHeaderView(
            title: "Some Long Text here",
            foregroundImage: Image.swiftLeedsIcon,
        )
        Text(verbatim: "Remote Data")
        FancyHeaderView(
            title: "Speaker Two",
            foregroundImageURLs: remoteImageURLs,
        )
    }
}

#Preview("Scrolling") {
    ScrollView {
        Text(verbatim: "Local Asset")
        VStack {
            FancyHeaderView(
                title: "Speaker One",
                foregroundImage: Image.swiftLeedsIcon,
            )
        }
        Text(verbatim: "Remote Data")
        FancyHeaderView(
            title: "Speaker Two",
            foregroundImageURLs: remoteImageURLs,
        )
    }
}

/// The remote photo addresses the previews load.
private let remoteImageURLs = [
    URL(string: "https://images.example.com/venue-banner.jpg")
].compactMap { $0 }
#endif
