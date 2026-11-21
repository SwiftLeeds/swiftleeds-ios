import SFSafeSymbols
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
///
/// While the picture loads, a photo draws a plain fill. If there is no URL, or
/// the picture fails to load, it draws a fallback instead.
///
/// ```swift
/// Photo(url: activity.imageURL) {
///     Artwork(icon: Icon(.hammerFill), palette: .teal)
/// }
/// ```
///
/// ### Naming a photo for VoiceOver
///
/// A photo is decoration. VoiceOver skips it and its fallback, so a photo
/// beside a title adds no element. If the photo shows something the text
/// does not, make it one element, describe what it shows and mark it as an
/// image.
///
/// ```swift
/// Photo(url: venue.entrancePhotoURL)
///     .accessibilityElement()
///     .accessibilityLabel("The main entrance, with a ramp to the left")
///     .accessibilityAddTraits(.isImage)
/// ```
///
/// The label stays when the picture fails to load, so describe the place
/// rather than the picture.
public struct Photo<Fallback: View>: View {
    /// Where a photo gets its picture from.
    private enum Source {
        /// A URL to load from, or `nil` when no picture was provided.
        case url(URL?)
        /// A phase of loading, drawn as it is.
        case phase(AsyncImagePhase)
    }

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

    /// Where the picture comes from.
    private let source: Source

    /// What to draw when there is no picture to show.
    private let fallback: Fallback

    /// Creates a photo that draws `fallback` when it has no picture to show.
    ///
    /// - Parameters:
    ///   - url: Where the picture loads from. A `nil` url draws the fallback.
    ///   - fallback: A content builder that creates what to draw when there is
    ///     no picture to show. It does not show while the picture loads.
    public init(url: URL?, @ViewBuilder fallback: () -> Fallback) {
        source = .url(url)
        self.fallback = fallback()
    }

    /// Creates a photo that draws one phase of loading, for tests and previews.
    ///
    /// - Parameters:
    ///   - phase: The phase to draw.
    ///   - fallback: A content builder that creates what to draw when the
    ///     phase is a failure.
    package init(phase: AsyncImagePhase, @ViewBuilder fallback: () -> Fallback) {
        source = .phase(phase)
        self.fallback = fallback()
    }

    public var body: some View {
        AnyView(resolved(in: style))
    }

    /// The properties handed to the current photo style.
    private var configuration: PhotoStyleConfiguration {
        PhotoStyleConfiguration(content: content)
    }

    /// The picture or the fallback, filling the frame and cropped to it.
    private var content: some View {
        Color.clear
            .overlay { shown }
            .clipped()
            .accessibilityHidden(true)
    }

    /// What the photo shows now, by where its picture comes from.
    @ViewBuilder private var shown: some View {
        switch source {
        case .url(let url?):
            AsyncImage(url: url) { phase in
                drawing(phase)
            }

        case .url(nil):
            fallback

        case .phase(let phase):
            drawing(phase)
        }
    }

    /// Returns what the photo draws in one phase of loading.
    ///
    /// - Parameter phase: The phase to draw.
    /// - Returns: The picture when it loaded, the fallback when it failed, and
    ///   nothing while it loads.
    @ViewBuilder
    private func drawing(_ phase: AsyncImagePhase) -> some View {
        if let image = phase.image {
            image
                .resizable()
                .scaledToFill()
        } else if phase.error != nil {
            fallback
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
    /// Creates a photo that shows the grey fill when it has no picture to show.
    ///
    /// - Parameter url: Where the picture loads from. A `nil` url shows the fill.
    public init(url: URL?) {
        self.init(url: url) { EmptyView() }
    }
}

#Preview("No picture") {
    Photo(url: nil) {
        Artwork(icon: Icon(.hammerFill), palette: .teal)
    }
    .frame(avatarSize: .xLarge)
    .padding(.lg)
}

#Preview("Loading") {
    Photo(phase: .empty) {
        Artwork(icon: Icon(.hammerFill), palette: .teal)
    }
    .frame(avatarSize: .xLarge)
    .padding(.lg)
}

#if DEBUG
#Preview("Loaded") {
    Photo(phase: .success(.previewPhoto)) {
        Artwork(icon: Icon(.hammerFill), palette: .teal)
    }
    .frame(avatarSize: .xLarge)
    .padding(.lg)
}
#endif

#Preview("Failed") {
    Photo(phase: .failure(URLError(.badServerResponse))) {
        Artwork(icon: Icon(.hammerFill), palette: .teal)
    }
    .frame(avatarSize: .xLarge)
    .padding(.lg)
}
