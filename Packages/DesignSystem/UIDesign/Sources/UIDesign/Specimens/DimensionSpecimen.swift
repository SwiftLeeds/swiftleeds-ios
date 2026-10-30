#if DEBUG
import SwiftUI

/// A view that shows one dimension's tokens beside their names.
package struct DimensionSpecimen: View {
    /// A kind of dimension token that a specimen can show.
    package enum Dimension: CaseIterable, Equatable, Hashable, Sendable {
        /// The ``Spacing`` scale.
        case spacing

        /// The ``CornerRadiusLevel`` scale, then the nested shape.
        case cornerRadius

        /// The ``BorderWidthLevel`` scale.
        case borderWidth

        /// The ``LineWidthLevel`` scale.
        case lineWidth

        /// The ``IconSize`` scale.
        case iconSize

        /// The ``AvatarSize`` scale.
        case avatarSize
    }

    /// A view that draws a bar as wide as a spacing token.
    private struct Bar: View {
        /// The spacing token the bar's width shows.
        let width: Spacing

        /// A bar filled with the primary color.
        var body: some View {
            Rectangle()
                .fill(.primary)
                .frame(width: CGFloat(width), height: CGFloat(Spacing.md))
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
                    HStack(spacing: .sm) {
                        ConcentricRectangle()
                            .fill(.primary)
                        ConcentricRectangle.nested
                            .fill(.primary)
                    }
                    .padding(.lg)
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
                .frame(iconSize: side)
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

    /// The dimension the specimen shows.
    private let dimension: Dimension

    /// Creates a specimen of one dimension.
    ///
    /// - Parameter dimension: The dimension to show.
    package init(_ dimension: Dimension) {
        self.dimension = dimension
    }

    /// The chosen dimension's tokens, padded.
    package var body: some View {
        group
            .padding(.lg)
    }

    /// The group of tokens for the chosen dimension.
    @ViewBuilder
    private var group: some View {
        switch dimension {
        case .spacing:
            spacingGroup

        case .cornerRadius:
            cornerRadiusGroup

        case .borderWidth:
            borderWidthGroup

        case .lineWidth:
            lineWidthGroup

        case .iconSize:
            iconSizeGroup

        case .avatarSize:
            avatarSizeGroup
        }
    }
}

// MARK: - Groups

extension DimensionSpecimen {
    /// The spacing scale, from the smallest to the largest.
    fileprivate var spacingGroup: some View {
        SpecimenGroup("Spacing") {
            GridRow {
                Text("xxs")
                Bar(width: .xxs)
            }
            GridRow {
                Text("xs")
                Bar(width: .xs)
            }
            GridRow {
                Text("sm")
                Bar(width: .sm)
            }
            GridRow {
                Text("md")
                Bar(width: .md)
            }
            GridRow {
                Text("lg")
                Bar(width: .lg)
            }
            GridRow {
                Text("xl")
                Bar(width: .xl)
            }
            GridRow {
                Text("xxl")
                Bar(width: .xxl)
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

    /// The icon size scale, from the smallest to the largest.
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

    /// The avatar size scale, from the smallest to the largest.
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
        VStack(alignment: .leading, spacing: .xl) {
            ForEach(DimensionSpecimen.Dimension.allCases, id: \.self) {
                DimensionSpecimen($0)
            }
        }
    }
}
#endif
