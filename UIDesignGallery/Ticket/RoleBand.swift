import SwiftUI
import UIDesign

/// A view that names a ticket's role in white on a flat band of the role's color.
struct RoleBand: View {
    /// The role the band names.
    let role: TicketRole

    /// Whether the band draws the role's texture.
    let variant: BandVariant

    /// Whether the person asked the system for stronger contrast.
    @Environment(\.colorSchemeContrast) private var contrast

    /// How much black the color takes when contrast is increased.
    private static let darkening: Double = 0.2

    /// The blur radius of each of the three stacked shadows that clear the
    /// pattern from around the label.
    private static let haloRadius: CGFloat = 1.5

    /// The color of the band, darker when contrast is increased.
    private var fill: Color {
        switch contrast {
        case .increased: role.color.mix(with: .black, by: Self.darkening)
        default: role.color
        }
    }

    var body: some View {
        Label(role.name, systemImage: role.symbol)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.white)
            .shadow(color: fill, radius: Self.haloRadius)
            .shadow(color: fill, radius: Self.haloRadius)
            .shadow(color: fill, radius: Self.haloRadius)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, .large)
            .padding(.vertical, .medium)
            .background { background }
    }

    /// The flat color, with the texture over it when the variant asks for one.
    private var background: some View {
        ZStack {
            fill

            if variant == .patterned {
                BandPatternView(pattern: role.pattern)
            }
        }
    }
}
