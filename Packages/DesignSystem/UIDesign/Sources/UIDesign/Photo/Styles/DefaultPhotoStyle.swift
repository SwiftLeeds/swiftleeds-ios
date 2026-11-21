import SwiftUI

/// The default photo style.
public struct DefaultPhotoStyle: PhotoStyle {
    /// Creates the default photo style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .background(.avatarFill)
    }
}

extension PhotoStyle where Self == DefaultPhotoStyle {
    /// The default photo style.
    public static var automatic: DefaultPhotoStyle { DefaultPhotoStyle() }
}
