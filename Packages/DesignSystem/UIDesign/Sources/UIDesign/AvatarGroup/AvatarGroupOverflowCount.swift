import SwiftUI

/// A view that draws the count of the people an avatar group has no room for.
///
/// It fills its container with the avatar fill and draws the count at the size
/// of an avatar's initials.
struct AvatarGroupOverflowCount: View {
    /// The diameter of the avatar containing this view.
    @Environment(\.avatarDiameter) private var diameter

    /// The number of people the group has no room for.
    private let hiddenCount: Int

    /// The count's font size, as a fraction of the avatar's diameter.
    private static let proportion: CGFloat = 0.40

    /// The largest count drawn in full, past which the view draws it with a plus.
    private static let largestFullCount = 99

    /// Creates a view that draws a count of hidden people.
    ///
    /// - Parameter hiddenCount: How many people the group has no room for.
    init(_ hiddenCount: Int) {
        self.hiddenCount = hiddenCount
    }

    var body: some View {
        Rectangle().fill(.avatarFill)
            .overlay {
                label
                    .font(.system(size: CGFloat(diameter) * Self.proportion, weight: .medium))
                    .foregroundStyle(.avatarInitials)
                    .lineLimit(1)
            }
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
