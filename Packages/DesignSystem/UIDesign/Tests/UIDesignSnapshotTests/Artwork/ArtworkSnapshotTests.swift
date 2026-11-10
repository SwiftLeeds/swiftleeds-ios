#if os(iOS)
import SFSafeSymbols
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct ArtworkSnapshotTests {
    /// The width and height of a thumbnail.
    private static let thumbnailSide: CGFloat = 56

    /// The width of a hero.
    private static let heroWidth: CGFloat = 375

    /// The height of a hero.
    private static let heroHeight: CGFloat = 250

    /// The four palettes with a symbol each, so the image can tell them apart.
    private static let artworks: [(icon: Icon, palette: Artwork.Palette)] = [
        (Icon(.microphoneFill), .blue),
        (Icon(.boltFill), .violet),
        (Icon(.hammerFill), .teal),
        (Icon(.person2Fill), .raspberry),
    ]

    /// The four palettes side by side, each clipped to a tile.
    private var thumbnailStrip: some View {
        HStack(spacing: .md) {
            ForEach(Self.artworks.indices, id: \.self) { index in
                Artwork(icon: Self.artworks[index].icon, palette: Self.artworks[index].palette)
                    .frame(width: Self.thumbnailSide, height: Self.thumbnailSide)
                    .clipShape(RoundedRectangle(cornerRadius: .tile))
            }
        }
        .padding(.lg)
    }

    /// The four palettes stacked, each as wide as a phone screen.
    private var heroStack: some View {
        VStack(spacing: .md) {
            ForEach(Self.artworks.indices, id: \.self) { index in
                Artwork(icon: Self.artworks[index].icon, palette: Self.artworks[index].palette)
                    .frame(width: Self.heroWidth, height: Self.heroHeight)
            }
        }
        .padding(.lg)
    }

    @Test func thumbnails() {
        assertContrastSnapshots(of: thumbnailStrip)
    }

    @Test func heroes() {
        assertContrastSnapshots(of: heroStack)
    }

    @Test func thumbnailsAtLargestTextSize() {
        assertSpecimenSnapshots(of: thumbnailStrip.dynamicTypeSize(.accessibility5))
    }
}
#endif
