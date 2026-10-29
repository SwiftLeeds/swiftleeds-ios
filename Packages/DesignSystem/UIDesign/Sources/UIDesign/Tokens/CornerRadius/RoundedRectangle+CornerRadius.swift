import SwiftUI

extension RoundedRectangle {
    /// Creates a rounded rectangle with a corner radius token.
    ///
    /// - Parameters:
    ///   - cornerRadius: The corner radius token for every corner.
    ///   - style: The style of the corners. The default is continuous.
    public init(cornerRadius: CornerRadius, style: RoundedCornerStyle = .continuous) {
        self.init(cornerRadius: CGFloat(cornerRadius), style: style)
    }
}
