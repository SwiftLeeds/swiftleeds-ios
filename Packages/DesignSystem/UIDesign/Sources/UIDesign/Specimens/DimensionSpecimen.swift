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

    /// A view that draws a filled rectangle with a corner radius level.
    private struct Corner: View {
        /// The corner radius level the rectangle shows.
        let level: CornerRadiusLevel

        /// A sample rectangle with the level applied to its corners.
        var body: some View {
            RoundedRectangle(cornerRadius: CGFloat(level))
                .fill(.primary)
                .frame(width: Sample.width, height: Sample.height)
        }
    }

    /// A view that draws a plain concentric shape beside the nested shape inside a rounded card.
    private struct Nested: View {
        /// The width of the card.
        private static let cardWidth: CGFloat = 128

        /// The height of the card.
        private static let cardHeight: CGFloat = 80

        /// The shape of the card, and the container shape of what it holds.
        private var cardShape: RoundedRectangle {
            RoundedRectangle(cornerRadius: CGFloat(CornerRadiusLevel.points24))
        }

        /// A card holding a plain concentric shape and the nested shape side by side.
        var body: some View {
            cardShape
                .fill(.secondary)
                .frame(width: Self.cardWidth, height: Self.cardHeight)
                .overlay {
                    HStack(spacing: .small) {
                        ConcentricRectangle()
                            .fill(.primary)
                        ConcentricRectangle.nested
                            .fill(.primary)
                    }
                    .padding(.large)
                    .containerShape(cardShape)
                }
        }
    }

    /// A view that draws an outlined rectangle with a border width level.
    private struct Border: View {
        /// The border width level the outline shows.
        let level: BorderWidthLevel

        /// A sample rectangle outlined at the level.
        var body: some View {
            RoundedRectangle(cornerRadius: .tile)
                .strokeBorder(.primary, lineWidth: CGFloat(level))
                .frame(width: Sample.width, height: Sample.height)
        }
    }

    /// A view that draws a horizontal bar as thick as a line width level.
    private struct Line: View {
        /// The line width level the bar shows.
        let level: LineWidthLevel

        /// A bar filled with the primary color, as thick as the level.
        var body: some View {
            Rectangle()
                .fill(.primary)
                .frame(width: Sample.width, height: CGFloat(level))
        }
    }

    /// A view that draws a square as large as an icon size token.
    private struct Square: View {
        /// The icon size token the square shows.
        let side: IconSize

        /// A square whose sides are the icon size.
        var body: some View {
            RoundedRectangle(cornerRadius: .tile)
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
        lineWidthGroup
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

    /// The corner radius scale, from the smallest to the largest, then the nested shape.
    fileprivate var cornerRadiusGroup: some View {
        SpecimenGroup("Radius") {
            GridRow {
                Text("points8")
                Corner(level: .points8)
            }
            GridRow {
                Text("points12")
                Corner(level: .points12)
            }
            GridRow {
                Text("points16")
                Corner(level: .points16)
            }
            GridRow {
                Text("points24")
                Corner(level: .points24)
            }
            GridRow {
                Text("nested")
                Nested()
            }
        }
    }

    /// The border width scale, from thin to thick.
    fileprivate var borderWidthGroup: some View {
        SpecimenGroup("Border") {
            GridRow {
                Text("thin")
                Border(level: .thin)
            }
            GridRow {
                Text("medium")
                Border(level: .medium)
            }
            GridRow {
                Text("thick")
                Border(level: .thick)
            }
        }
    }

    /// The line width scale, from thin to thick.
    fileprivate var lineWidthGroup: some View {
        SpecimenGroup("Line") {
            GridRow {
                Text("points2")
                Line(level: .points2)
            }
            GridRow {
                Text("points3")
                Line(level: .points3)
            }
            GridRow {
                Text("points4")
                Line(level: .points4)
            }
            GridRow {
                Text("points5")
                Line(level: .points5)
            }
            GridRow {
                Text("points6")
                Line(level: .points6)
            }
            GridRow {
                Text("points7")
                Line(level: .points7)
            }
            GridRow {
                Text("points8")
                Line(level: .points8)
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
