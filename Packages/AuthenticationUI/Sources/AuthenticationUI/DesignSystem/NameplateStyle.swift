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
        HStack(spacing: 12) {
            configuration.icon
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 2) {
                configuration.title
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)

                configuration.detail
                    .font(.subheadline)
                    .foregroundStyle(configuration.role.detailStyle)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
    }
}

package struct CompactNameplateStyle: NameplateStyle {
    package init() {}

    package func makeBody(configuration: NameplateStyleConfiguration) -> some View {
        HStack(spacing: 10) {
            configuration.icon
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 1) {
                configuration.title
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                configuration.detail
                    .font(.footnote)
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
