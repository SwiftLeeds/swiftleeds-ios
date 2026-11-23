import Foundation
import SwiftUI

/// A view that draws the count of the people an avatar group has no room for.
///
/// It draws the count on a plain fill, as an avatar draws its initials, but never shrinks it.
struct AvatarGroupOverflowCount: View {
    /// The number of people the group has no room for.
    private let hiddenCount: Int

    /// The largest count drawn in full, past which the view draws it with a plus.
    private static let largestFullCount = 99

    /// Creates a view that draws a count of hidden people.
    ///
    /// - Parameter hiddenCount: How many people the group has no room for.
    init(_ hiddenCount: Int) {
        self.hiddenCount = hiddenCount
    }

    var body: some View {
        AvatarFillText(label, shrinksToFit: false)
    }

    /// The count as text, with a leading plus, or the largest full count and a plus past it.
    private var label: Text {
        if hiddenCount > Self.largestFullCount {
            Text("\(Self.largestFullCount, format: .number)+", bundle: .module)
        } else {
            Text(hiddenCount, format: .number.sign(strategy: .always()))
        }
    }
}
