import Foundation
import SwiftUI

/// A view that shows a company's mark, fitted whole inside its frame.
///
/// The mark loads from `url`. It keeps its proportions, so a wide mark leaves
/// space above and below it rather than being cropped or stretched. The frame
/// is the caller's, and a screen scales it with `@ScaledMetric`.
///
/// ```swift
/// Logo(url: sponsor.logoURL)
///     .frame(width: 56, height: 56)
/// ```
///
/// ## Making a logo accessible
///
/// A logo adds nothing to the accessibility tree until its caller names it. Its
/// mark and its fallback are hidden from VoiceOver, so the fallback never reads
/// as text and a mark that failed to load leaves no gap.
///
/// Name a logo that carries information, such as a sponsor's mark on its own.
/// Make it one element, give it the company's name, and mark it as an image:
///
/// ```swift
/// Logo(url: sponsor.logoURL)
///     .frame(width: 56, height: 56)
///     .accessibilityElement()
///     .accessibilityLabel("Example Co")
///     .accessibilityAddTraits(.isImage)
/// ```
///
/// Leave a logo unnamed when the company's name sits beside it, because the
/// logo then repeats what that text says.
public struct Logo<Fallback: View>: View {
    /// Where the mark comes from.
    private enum Source {
        /// The caller provided no URL.
        case noLogo

        /// The mark loads from this URL.
        case url(URL)

        /// A phase of loading, drawn as it is.
        case phase(AsyncImagePhase)
    }

    /// A view that draws a logo in a given style.
    private struct ResolvedLogoStyle<Style: LogoStyle>: View {
        /// The style that draws the logo.
        let style: Style

        /// The properties of the logo.
        let configuration: LogoStyleConfiguration

        var body: some View {
            style.makeBody(configuration: configuration)
        }
    }

    /// The current logo style.
    @Environment(\.logoStyle) private var style

    /// Where the mark comes from.
    private let source: Source

    /// What to draw when there is no mark to show.
    private let fallback: Fallback

    /// Creates a logo that loads its mark from a URL, with a view to draw when there is no mark.
    ///
    /// ```swift
    /// Logo(url: sponsor.logoURL) {
    ///     Text("EX")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - url: Where the mark loads from. A `nil` url draws the fallback.
    ///   - fallback: A content builder that creates what to draw when there is no mark to show.
    ///     It does not show while the logo loads.
    public init(url: URL?, @ViewBuilder fallback: () -> Fallback) {
        source = url.map(Source.url) ?? .noLogo
        self.fallback = fallback()
    }

    /// Creates a logo that draws one phase of loading, for tests and previews.
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

    /// The properties handed to the current logo style.
    private var configuration: LogoStyleConfiguration {
        LogoStyleConfiguration(content: content.accessibilityHidden(true))
    }

    /// The mark fitted to the frame, the fallback standing in for it, or nothing while it loads.
    @ViewBuilder
    private var content: some View {
        switch source {
        case .noLogo:
            fallback

        case .url(let url):
            AsyncImage(url: url) { phase in
                drawing(phase)
            }

        case .phase(let phase):
            drawing(phase)
        }
    }

    /// Returns what the logo draws in one phase of loading.
    ///
    /// - Parameter phase: The phase to draw.
    /// - Returns: The mark fitted to the frame when it loaded, the fallback
    ///   when it failed, and nothing while it loads.
    @ViewBuilder
    private func drawing(_ phase: AsyncImagePhase) -> some View {
        if let image = phase.image {
            image
                .resizable()
                .scaledToFit()
        } else if phase.error != nil {
            fallback
        }
    }

    /// Returns a view that draws the logo in the given style.
    ///
    /// - Parameter style: The style to draw the logo in.
    /// - Returns: A view that draws the logo in `style`.
    private func resolved(in style: some LogoStyle) -> some View {
        ResolvedLogoStyle(style: style, configuration: configuration)
    }
}

#if DEBUG
#Preview("No logo") {
    Logo(url: nil) { Text("EX") }
        .frame(width: 56, height: 56)
        .padding()
}

#Preview("Loading") {
    Logo(phase: .empty) { Text("EX") }
        .frame(width: 56, height: 56)
        .padding()
}

#Preview("Loaded") {
    Logo(phase: .success(.previewMark)) { Text("EX") }
        .frame(width: 56, height: 56)
        .padding()
}

#Preview("Failed") {
    Logo(phase: .failure(URLError(.badServerResponse))) { Text("EX") }
        .frame(width: 56, height: 56)
        .padding()
}
#endif

extension Logo where Fallback == EmptyView {
    /// Creates a logo that loads its mark from a URL.
    ///
    /// - Parameter url: Where the mark loads from. A `nil` url draws nothing and asks for nothing.
    public init(url: URL?) {
        self.init(url: url) { EmptyView() }
    }
}
