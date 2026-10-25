#if DEBUG
import SwiftUI

/// Draws every dimension token beside its name.
package struct DimensionSpecimen: View {
    /// A view that draws a bar as wide as a spacing token.
    private struct Bar: View {
        /// The spacing token the bar's width shows.
        let width: Spacing

        /// A bar filled with the primary color.
        var body: some View {
            Rectangle()
                .fill(.primary)
                .frame(width: CGFloat(width), height: CGFloat(Spacing.medium))
        }
    }

    /// A view that draws a filled rectangle with a corner radius token.
    private struct Corner: View {
        /// The corner radius token the rectangle shows.
        let radius: CornerRadius

        /// A sample rectangle with the radius applied to its corners.
        var body: some View {
            RoundedRectangle(cornerRadius: CGFloat(radius))
                .fill(.primary)
                .frame(width: Sample.width, height: Sample.height)
        }
    }

    /// A view that draws an outlined rectangle with a border width token.
    private struct Border: View {
        /// The border width token the outline shows.
        let width: BorderWidth

        /// A sample rectangle outlined at the border width.
        var body: some View {
            RoundedRectangle(cornerRadius: CGFloat(CornerRadius.small))
                .strokeBorder(.primary, lineWidth: CGFloat(width))
                .frame(width: Sample.width, height: Sample.height)
        }
    }

    /// A view that draws a square as large as an icon size token.
    private struct Square: View {
        /// The icon size token the square shows.
        let side: IconSize

        /// A square whose sides are the icon size.
        var body: some View {
            RoundedRectangle(cornerRadius: CGFloat(CornerRadius.small))
                .fill(.primary)
                .frame(side)
        }
    }

    /// A view that draws a circle as large as an avatar size token.
    private struct Dot: View {
        /// The avatar size token the circle shows.
        let diameter: AvatarSize

        /// A circle as wide as the avatar size.
        var body: some View {
            Circle()
                .fill(.primary)
                .frame(diameter)
        }
    }

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

extension DimensionSpecimen {
    fileprivate var spacingGroup: some View {
        SpecimenGroup("Spacing") {
            GridRow {
                Text("xxSmall")
                Bar(width: .xxSmall)
            }
            GridRow {
                Text("xSmall")
                Bar(width: .xSmall)
            }
            GridRow {
                Text("small")
                Bar(width: .small)
            }
            GridRow {
                Text("medium")
                Bar(width: .medium)
            }
            GridRow {
                Text("large")
                Bar(width: .large)
            }
            GridRow {
                Text("xLarge")
                Bar(width: .xLarge)
            }
            GridRow {
                Text("xxLarge")
                Bar(width: .xxLarge)
            }
        }
    }

    fileprivate var cornerRadiusGroup: some View {
        SpecimenGroup("Radius") {
            GridRow {
                Text("zero")
                Corner(radius: .zero)
            }
            GridRow {
                Text("small")
                Corner(radius: .small)
            }
            GridRow {
                Text("medium")
                Corner(radius: .medium)
            }
            GridRow {
                Text("large")
                Corner(radius: .large)
            }
            GridRow {
                Text("xLarge")
                Corner(radius: .xLarge)
            }
            GridRow {
                Text("full")
                Corner(radius: .full)
            }
        }
    }

    fileprivate var borderWidthGroup: some View {
        SpecimenGroup("Border") {
            GridRow {
                Text("thin")
                Border(width: .thin)
            }
            GridRow {
                Text("medium")
                Border(width: .medium)
            }
            GridRow {
                Text("thick")
                Border(width: .thick)
            }
        }
    }

    fileprivate var iconSizeGroup: some View {
        SpecimenGroup("Icon") {
            GridRow {
                Text("xSmall")
                Square(side: .xSmall)
            }
            GridRow {
                Text("small")
                Square(side: .small)
            }
            GridRow {
                Text("medium")
                Square(side: .medium)
            }
            GridRow {
                Text("large")
                Square(side: .large)
            }
            GridRow {
                Text("xLarge")
                Square(side: .xLarge)
            }
            GridRow {
                Text("xxLarge")
                Square(side: .xxLarge)
            }
        }
    }

    fileprivate var avatarSizeGroup: some View {
        SpecimenGroup("Avatar") {
            GridRow {
                Text("small")
                Dot(diameter: .small)
            }
            GridRow {
                Text("medium")
                Dot(diameter: .medium)
            }
            GridRow {
                Text("large")
                Dot(diameter: .large)
            }
            GridRow {
                Text("xLarge")
                Dot(diameter: .xLarge)
            }
        }
    }
}

#Preview {
    ScrollView([.horizontal, .vertical]) {
        DimensionSpecimen()
    }
}
#endif
