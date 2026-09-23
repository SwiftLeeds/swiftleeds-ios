#if DEBUG
import SwiftUI

/// Draws every dimension token beside its name.
package struct DimensionSpecimen: View {
    package init() {}

    package var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: Spacing.xLarge) { groups }
            VStack(alignment: .leading, spacing: Spacing.xLarge) { groups }
        }
        .padding(Spacing.large)
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
            GridRow { Text("xxSmall"); Bar(width: Spacing.xxSmall) }
            GridRow { Text("xSmall"); Bar(width: Spacing.xSmall) }
            GridRow { Text("small"); Bar(width: Spacing.small) }
            GridRow { Text("medium"); Bar(width: Spacing.medium) }
            GridRow { Text("large"); Bar(width: Spacing.large) }
            GridRow { Text("xLarge"); Bar(width: Spacing.xLarge) }
            GridRow { Text("xxLarge"); Bar(width: Spacing.xxLarge) }
        }
    }

    var cornerRadiusGroup: some View {
        SpecimenGroup("Radius") {
            GridRow { Text("none"); Corner(radius: CornerRadius.none) }
            GridRow { Text("small"); Corner(radius: CornerRadius.small) }
            GridRow { Text("medium"); Corner(radius: CornerRadius.medium) }
            GridRow { Text("large"); Corner(radius: CornerRadius.large) }
            GridRow { Text("xLarge"); Corner(radius: CornerRadius.xLarge) }
            GridRow { Text("full"); Corner(radius: CornerRadius.full) }
        }
    }

    var borderWidthGroup: some View {
        SpecimenGroup("Border") {
            GridRow { Text("thin"); Border(width: BorderWidth.thin) }
            GridRow { Text("medium"); Border(width: BorderWidth.medium) }
            GridRow { Text("thick"); Border(width: BorderWidth.thick) }
        }
    }

    var iconSizeGroup: some View {
        SpecimenGroup("Icon") {
            GridRow { Text("xSmall"); Square(side: IconSize.xSmall) }
            GridRow { Text("small"); Square(side: IconSize.small) }
            GridRow { Text("medium"); Square(side: IconSize.medium) }
            GridRow { Text("large"); Square(side: IconSize.large) }
            GridRow { Text("xLarge"); Square(side: IconSize.xLarge) }
            GridRow { Text("xxLarge"); Square(side: IconSize.xxLarge) }
        }
    }

    var avatarSizeGroup: some View {
        SpecimenGroup("Avatar") {
            GridRow { Text("small"); Dot(diameter: AvatarSize.small) }
            GridRow { Text("medium"); Dot(diameter: AvatarSize.medium) }
            GridRow { Text("large"); Dot(diameter: AvatarSize.large) }
            GridRow { Text("xLarge"); Dot(diameter: AvatarSize.xLarge) }
        }
    }
}

// MARK: - Parts

private struct Bar: View {
    let width: CGFloat

    var body: some View {
        Rectangle()
            .fill(.primary)
            .frame(width: width, height: Spacing.medium)
    }
}

private struct Corner: View {
    let radius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(.primary)
            .frame(width: Sample.width, height: Sample.height)
    }
}

private struct Border: View {
    let width: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: CornerRadius.small)
            .strokeBorder(.primary, lineWidth: width)
            .frame(width: Sample.width, height: Sample.height)
    }
}

private struct Square: View {
    let side: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: CornerRadius.small)
            .fill(.primary)
            .frame(width: side, height: side)
    }
}

private struct Dot: View {
    let diameter: CGFloat

    var body: some View {
        Circle()
            .fill(.primary)
            .frame(width: diameter, height: diameter)
    }
}

#Preview {
    ScrollView([.horizontal, .vertical]) {
        DimensionSpecimen()
    }
}
#endif
