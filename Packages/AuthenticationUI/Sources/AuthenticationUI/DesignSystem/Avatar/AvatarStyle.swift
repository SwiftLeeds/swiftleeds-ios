import SwiftUI

package enum AvatarContentKind: Equatable, Sendable {
    case image
    case placeholder
    case failure
}

package struct AvatarStyleConfiguration {
    package struct Content: View {
        let base: AnyView

        package var body: some View { base }
    }

    package let content: Content
    package let kind: AvatarContentKind
}

package protocol AvatarStyle {
    associatedtype Body: View

    @ViewBuilder func makeBody(configuration: AvatarStyleConfiguration) -> Body
}

package struct CircularAvatarStyle: AvatarStyle {
    package init() {}

    package func makeBody(configuration: AvatarStyleConfiguration) -> some View {
        Color.clear
            .background(configuration.kind.fill)
            .overlay { configuration.content }
            .clipShape(Circle())
    }
}

package struct RoundedAvatarStyle: AvatarStyle {
    private let cornerRadius: CGFloat

    package init(cornerRadius: CGFloat = 12) {
        self.cornerRadius = cornerRadius
    }

    package func makeBody(configuration: AvatarStyleConfiguration) -> some View {
        Color.clear
            .background(configuration.kind.fill)
            .overlay { configuration.content }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

package extension AvatarContentKind {
    var fill: AnyShapeStyle {
        switch self {
        case .image: AnyShapeStyle(.clear)
        case .placeholder, .failure: AnyShapeStyle(.tint.opacity(0.15))
        }
    }
}

package extension AvatarStyle where Self == CircularAvatarStyle {
    static var circular: CircularAvatarStyle { CircularAvatarStyle() }
}

package extension AvatarStyle where Self == RoundedAvatarStyle {
    static var rounded: RoundedAvatarStyle { RoundedAvatarStyle() }

    static func rounded(cornerRadius: CGFloat) -> RoundedAvatarStyle {
        RoundedAvatarStyle(cornerRadius: cornerRadius)
    }
}

struct AnyAvatarStyle {
    let makeBody: (AvatarStyleConfiguration) -> AnyView

    init<S: AvatarStyle>(_ style: S) {
        makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }
}

private struct AvatarStyleKey: EnvironmentKey {
    static var defaultValue: AnyAvatarStyle { AnyAvatarStyle(CircularAvatarStyle()) }
}

extension EnvironmentValues {
    var avatarStyle: AnyAvatarStyle {
        get { self[AvatarStyleKey.self] }
        set { self[AvatarStyleKey.self] = newValue }
    }
}

package extension View {
    func avatarStyle<S: AvatarStyle>(_ style: S) -> some View {
        environment(\.avatarStyle, AnyAvatarStyle(style))
    }
}
