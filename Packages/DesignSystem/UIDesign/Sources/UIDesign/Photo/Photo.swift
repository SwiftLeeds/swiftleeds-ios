import SwiftUI

/// A view that shows a picture from a URL, filling its frame and cropped to it.
///
/// The picture loads from `url`. It fills the frame its caller gives it, and
/// whatever overflows the frame is cut off, so a photo never pushes its
/// neighbors aside.
///
/// ```swift
/// Photo(url: venue.photoURL)
///     .frame(width: 100, height: 150)
/// ```
public struct Photo<Fallback: View>: View {
    /// A view that draws a photo in a given style.
    private struct ResolvedPhotoStyle<Style: PhotoStyle>: View {
        /// The style that draws the photo.
        let style: Style

        /// The properties of the photo.
        let configuration: PhotoStyleConfiguration

        var body: some View {
            style.makeBody(configuration: configuration)
        }
    }

    /// The current photo style.
    @Environment(\.photoStyle) private var style

    /// Where the picture loads from.
    private let url: URL?

    public var body: some View {
        AnyView(resolved(in: style))
    }

    /// The properties handed to the current photo style.
    private var configuration: PhotoStyleConfiguration {
        PhotoStyleConfiguration(content: content)
    }

    /// The loaded picture, scaled to fill the frame and cropped to it.
    private var content: some View {
        Color.clear
            .overlay { picture }
            .clipped()
    }

    /// The loaded picture, scaled to fill the frame.
    private var picture: some View {
        AsyncImage(url: url) { phase in
            if case .success(let image) = phase {
                image
                    .resizable()
                    .scaledToFill()
            }
        }
    }

    /// Returns a view that draws the photo in the given style.
    ///
    /// - Parameter style: The style to draw the photo in.
    /// - Returns: A view that draws the photo in `style`.
    private func resolved(in style: some PhotoStyle) -> some View {
        ResolvedPhotoStyle(style: style, configuration: configuration)
    }
}

extension Photo where Fallback == EmptyView {
    /// Creates a photo that loads its picture from a URL.
    ///
    /// - Parameter url: Where the picture loads from.
    public init(url: URL?) {
        self.url = url
    }
}
