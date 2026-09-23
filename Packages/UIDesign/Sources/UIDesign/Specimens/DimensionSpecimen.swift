#if DEBUG
import SwiftUI

/// Draws every dimension token beside its name.
package struct DimensionSpecimen: View {
    package init() {}

    package var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: .xLarge) { groups }
            VStack(alignment: .leading, spacing: .xLarge) { groups }
        }
        .padding(.large)
    }

    @ViewBuilder
    private var groups: some View {
        spacingGroup
        cornerRadiusGroup
        borderWidthGroup
        iconSizeGroup
        avatarSizeGroup
    }
}

// MARK: - Groups

private extension DimensionSpecimen {
    var spacingGroup: some View {
        SpecimenGroup("Spacing") {
            GridRow { Text("xxSmall"); Bar(width: .xxSmall) }
            GridRow { Text("xSmall"); Bar(width: .xSmall) }
            GridRow { Text("small"); Bar(width: .small) }
            GridRow { Text("medium"); Bar(width: .medium) }
            GridRow { Text("large"); Bar(width: .large) }
            GridRow { Text("xLarge"); Bar(width: .xLarge) }
            GridRow { Text("xxLarge"); Bar(width: .xxLarge) }
        }
    }

    var cornerRadiusGroup: some View {
        SpecimenGroup("Radius") {
            GridRow { Text("none"); Corner(radius: .none) }
            GridRow { Text("small"); Corner(radius: .small) }
            GridRow { Text("medium"); Corner(radius: .medium) }
            GridRow { Text("large"); Corner(radius: .large) }
            GridRow { Text("xLarge"); Corner(radius: .xLarge) }
            GridRow { Text("full"); Corner(radius: .full) }
        }
    }

    var borderWidthGroup: some View {
        SpecimenGroup("Border") {
            GridRow { Text("thin"); Border(width: .thin) }
            GridRow { Text("medium"); Border(width: .medium) }
            GridRow { Text("thick"); Border(width: .thick) }
        }
    }

    var iconSizeGroup: some View {
        SpecimenGroup("Icon") {
            GridRow { Text("xSmall"); Square(side: .xSmall) }
            GridRow { Text("small"); Square(side: .small) }
            GridRow { Text("medium"); Square(side: .medium) }
            GridRow { Text("large"); Square(side: .large) }
            GridRow { Text("xLarge"); Square(side: .xLarge) }
            GridRow { Text("xxLarge"); Square(side: .xxLarge) }
        }
    }

    var avatarSizeGroup: some View {
        SpecimenGroup("Avatar") {
            GridRow { Text("small"); Dot(diameter: .small) }
            GridRow { Text("medium"); Dot(diameter: .medium) }
            GridRow { Text("large"); Dot(diameter: .large) }
            GridRow { Text("xLarge"); Dot(diameter: .xLarge) }
        }
    }
}

// MARK: - Parts

private struct Bar: View {
    let width: Spacing

    var body: some View {
        Rectangle()
            .fill(.primary)
            .frame(width: CGFloat(width), height: CGFloat(Spacing.medium))
    }
}

private struct Corner: View {
    let radius: CornerRadius

    var body: some View {
        RoundedRectangle(cornerRadius: CGFloat(radius))
            .fill(.primary)
            .frame(width: Sample.width, height: Sample.height)
    }
}

private struct Border: View {
    let width: BorderWidth

    var body: some View {
        RoundedRectangle(cornerRadius: CGFloat(CornerRadius.small))
            .strokeBorder(.primary, lineWidth: CGFloat(width))
            .frame(width: Sample.width, height: Sample.height)
    }
}

private struct Square: View {
    let side: IconSize

    var body: some View {
        RoundedRectangle(cornerRadius: CGFloat(CornerRadius.small))
            .fill(.primary)
            .frame(side)
    }
}

private struct Dot: View {
    let diameter: AvatarSize

    var body: some View {
        Circle()
            .fill(.primary)
            .frame(diameter)
    }
}

#Preview {
    ScrollView([.horizontal, .vertical]) {
        DimensionSpecimen()
    }
}
#endif
