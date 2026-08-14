import SwiftUI

package struct AvatarImage: View {
    private let image: Image

    init(_ image: Image) {
        self.image = image
    }

    package var body: some View {
        image
            .resizable()
            .scaledToFill()
    }
}

package struct Avatar<Content: View, Placeholder: View, Failure: View>: View {
    @Environment(\.avatarStyle) private var style

    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    private let failure: () -> Failure

    package init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder failure: @escaping () -> Failure
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
        self.failure = failure
    }

    package var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                styled(AnyView(content(image)), kind: .image)
            case .failure:
                styled(fitted(failure()), kind: .failure)
            case .empty:
                styled(fitted(placeholder()), kind: .placeholder)
            @unknown default:
                styled(fitted(placeholder()), kind: .placeholder)
            }
        }
        .accessibilityHidden(true)
    }

    private func fitted<V: View>(_ view: V) -> AnyView {
        AnyView(view.minimumScaleFactor(0.5))
    }

    private func styled(_ content: AnyView, kind: AvatarContentKind) -> some View {
        style.makeBody(
            AvatarStyleConfiguration(
                content: AvatarStyleConfiguration.Content(base: content),
                kind: kind
            )
        )
    }
}

package extension Avatar where Placeholder == Failure {
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder fallback: @escaping () -> Failure
    ) {
        self.init(url: url, content: content, placeholder: fallback, failure: fallback)
    }
}

package extension Avatar where Content == AvatarImage {
    init(
        url: URL?,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder failure: @escaping () -> Failure
    ) {
        self.init(url: url, content: { AvatarImage($0) }, placeholder: placeholder, failure: failure)
    }
}

package extension Avatar where Content == AvatarImage, Placeholder == Failure {
    init(url: URL?, @ViewBuilder fallback: @escaping () -> Failure) {
        self.init(url: url, content: { AvatarImage($0) }, placeholder: fallback, failure: fallback)
    }
}

#if DEBUG
#Preview("Avatar styles") {
    VStack(spacing: 24) {
        HStack(spacing: 16) {
            Avatar(url: nil) { Text(verbatim: "AL") }
                .frame(width: 88, height: 88)

            Avatar(url: nil) { Text(verbatim: "AL") }
                .frame(width: 56, height: 56)

            Avatar(url: nil) { Image(systemName: "person") }
                .frame(width: 40, height: 40)
        }
        .font(.title2.weight(.semibold))
        .foregroundStyle(Color.accentColor)

        HStack(spacing: 16) {
            Avatar(url: nil) { Text(verbatim: "AL") }
                .frame(width: 88, height: 88)

            Avatar(url: nil) { Text(verbatim: "AL") }
                .frame(width: 56, height: 56)

            Avatar(url: nil) { Image(systemName: "person") }
                .frame(width: 40, height: 40)
        }
        .font(.title2.weight(.semibold))
        .foregroundStyle(Color.accentColor)
        .avatarStyle(.rounded)
    }
    .padding()
}
#endif
