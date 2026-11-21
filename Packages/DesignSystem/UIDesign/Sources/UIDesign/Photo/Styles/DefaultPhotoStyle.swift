import SwiftUI

/// The default photo style.
///
/// It draws the grey fill behind the content.
public struct DefaultPhotoStyle: PhotoStyle {
    /// The reasons to redact the photo's content.
    @Environment(\.redactionReasons) private var redactionReasons

    /// Creates the default photo style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .background(redactionReasons.contains(.placeholder) ? AnyShapeStyle(.clear) : .avatarFill)
    }
}

extension PhotoStyle where Self == DefaultPhotoStyle {
    /// The default photo style.
    public static var automatic: DefaultPhotoStyle { DefaultPhotoStyle() }
}
