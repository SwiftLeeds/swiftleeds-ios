import SwiftUI

package enum NameplateRole: Equatable, Sendable {
    case standard
    case unresolved
}

package struct NameplateStyleConfiguration {
    package struct Title: View {
        let base: AnyView

        package var body: some View { base }
    }

    package struct Detail: View {
        let base: AnyView

        package var body: some View { base }
    }

    package struct Icon: View {
        let base: AnyView

        package var body: some View { base }
    }

    package let title: Title
    package let detail: Detail
    package let icon: Icon
    package let role: NameplateRole
}

package protocol NameplateStyle {
    associatedtype Body: View

    @ViewBuilder func makeBody(configuration: NameplateStyleConfiguration) -> Body
}

package struct ProminentNameplateStyle: NameplateStyle {
    package init() {}

    package func makeBody(configuration: NameplateStyleConfiguration) -> some View {
        ProminentBody(configuration: configuration)
    }

    private struct ProminentBody: View {
        @ScaledMetric(relativeTo: .title3) private var iconSize: CGFloat = 56

        let configuration: NameplateStyleConfiguration

        var body: some View {
            NameplateLayout(
                configuration: configuration,
                iconSize: min(iconSize, 96),
                spacing: 12,
                titleFont: .title3.weight(.semibold),
                detailFont: .subheadline
            )
            .padding(.vertical, 8)
        }
    }
}

package struct CompactNameplateStyle: NameplateStyle {
    package init() {}

    package func makeBody(configuration: NameplateStyleConfiguration) -> some View {
        CompactBody(configuration: configuration)
    }

    private struct CompactBody: View {
        @ScaledMetric(relativeTo: .subheadline) private var iconSize: CGFloat = 40

        let configuration: NameplateStyleConfiguration

        var body: some View {
            NameplateLayout(
                configuration: configuration,
                iconSize: min(iconSize, 72),
                spacing: 10,
                titleFont: .subheadline.weight(.semibold),
                detailFont: .footnote
            )
        }
    }
}

private struct NameplateLayout: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let configuration: NameplateStyleConfiguration
    let iconSize: CGFloat
    let spacing: CGFloat
    let titleFont: Font
    let detailFont: Font

    var body: some View {
        HStack(alignment: dynamicTypeSize.isAccessibilitySize ? .top : .center, spacing: spacing) {
            configuration.icon
                .font(titleFont)
                .foregroundStyle(Color.accentColor)
                .frame(width: iconSize, height: iconSize)

            VStack(alignment: .leading, spacing: 2) {
                configuration.title
                    .font(titleFont)
                    .foregroundStyle(.primary)

                configuration.detail
                    .font(detailFont)
                    .foregroundStyle(configuration.role.detailStyle)
            }

            Spacer(minLength: 0)
        }
    }
}

private extension NameplateRole {
    var detailStyle: AnyShapeStyle {
        switch self {
        case .standard: AnyShapeStyle(.secondary)
        case .unresolved: AnyShapeStyle(.tertiary)
        }
    }
}

package extension NameplateStyle where Self == ProminentNameplateStyle {
    static var prominent: ProminentNameplateStyle { ProminentNameplateStyle() }
}

package extension NameplateStyle where Self == CompactNameplateStyle {
    static var compact: CompactNameplateStyle { CompactNameplateStyle() }
}

struct AnyNameplateStyle {
    let makeBody: (NameplateStyleConfiguration) -> AnyView

    init<S: NameplateStyle>(_ style: S) {
        makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }
}

private struct NameplateStyleKey: EnvironmentKey {
    static var defaultValue: AnyNameplateStyle { AnyNameplateStyle(ProminentNameplateStyle()) }
}

extension EnvironmentValues {
    var nameplateStyle: AnyNameplateStyle {
        get { self[NameplateStyleKey.self] }
        set { self[NameplateStyleKey.self] = newValue }
    }
}

package extension View {
    func nameplateStyle<S: NameplateStyle>(_ style: S) -> some View {
        environment(\.nameplateStyle, AnyNameplateStyle(style))
    }
}
