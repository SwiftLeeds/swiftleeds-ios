#if canImport(UIKit)
import DesignKit
import SwiftUI

/// A card that names a place and links to its website.
package struct LocationCard: View {
    private let symbolName: String
    private let name: String
    private let websiteURL: URL

    /// Creates a card for a place.
    ///
    /// - Parameters:
    ///   - symbolName: The name of the SF Symbol, or asset catalog image, for the place's
    ///     category.
    ///   - name: The place's name.
    ///   - websiteURL: The place's website.
    package init(symbolName: String, name: String, websiteURL: URL) {
        self.symbolName = symbolName
        self.name = name
        self.websiteURL = websiteURL
    }

    package var body: some View {
        VStack(spacing: 10) {
            symbolImage(named: symbolName)
                .renderingMode(.template)
                .frame(width: 44, height: 44)

            Text(name)

            Button {
                UIApplication.shared.open(websiteURL)
            } label: {
                Text(verbatim: "View More")
                    .bold()
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.accent)
                    .background(Color.accent.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(10)
        .padding(.bottom, 5)
        .frame(width: 200)
        .foregroundColor(Color.cellForeground)
        .background(Color.cellBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

/// Resolves a symbol by name, falling back to an asset catalog image of the same name.
///
/// - Parameter name: The SF Symbol, or asset catalog image, name.
/// - Returns: The resolved image.
func symbolImage(named name: String) -> Image {
    Image(uiImage: UIImage(systemName: name) ?? UIImage(imageLiteralResourceName: name))
}

#Preview {
    if let websiteURL = URL(string: "https://example.com") {
        LocationCard(
            symbolName: "takeoutbag.and.cup.and.straw.fill",
            name: "Trinity Kitchen",
            websiteURL: websiteURL,
        )
    }
}
#endif
