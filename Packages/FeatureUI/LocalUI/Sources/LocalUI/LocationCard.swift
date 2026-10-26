#if canImport(UIKit)
import Foundation
import SwiftUI
import UIAssets
import UIKit

/// A card naming a place, with a link to its website when it has one.
package struct LocationCard: View {
    /// The place's category symbol: an SF Symbol, or asset catalog image name.
    private let symbolName: String

    /// The place's name.
    private let name: String

    /// The place's website.
    ///
    /// Absent when the place has no usable web address.
    private let websiteURL: URL?

    /// Called when the person dismisses the card.
    private let dismiss: () -> Void

    /// Creates a card for a place.
    package init(
        symbolName: String,
        name: String,
        websiteURL: URL?,
        dismiss: @escaping () -> Void,
    ) {
        self.symbolName = symbolName
        self.name = name
        self.websiteURL = websiteURL
        self.dismiss = dismiss
    }

    package var body: some View {
        VStack(spacing: 10) {
            symbolImage(named: symbolName)
                .renderingMode(.template)
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)

            Text(name)

            if let websiteURL {
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
                .padding(.bottom, 5)
            }
        }
        .padding(10)
        .frame(width: 200)
        .foregroundColor(Color.cellForeground)
        .background(Color.cellBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
        .accessibilityAction(.escape, dismiss)
    }
}

#Preview("With link") {
    LocationCard(
        symbolName: "takeoutbag.and.cup.and.straw.fill",
        name: "Trinity Kitchen",
        websiteURL: URL(string: "https://example.com"),
        dismiss: {},
    )
}

#Preview("Without link") {
    LocationCard(
        symbolName: "takeoutbag.and.cup.and.straw.fill",
        name: "Trinity Kitchen",
        websiteURL: nil,
        dismiss: {},
    )
}
#endif
