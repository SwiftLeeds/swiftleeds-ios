import SharedAssets
import SwiftUI

public struct SwiftLeedsContainer<Content: View>: View {
    private var content: () -> (Content)

    public init(@ViewBuilder content: @escaping () -> (Content)) {
        self.content = content
    }

    public var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            content()
        }
    }
}

struct SwiftLeedsContainer_Previews: PreviewProvider {
    static var previews: some View {
        SwiftLeedsContainer {
            Text(verbatim: "SwiftLeeds 22")
        }
    }
}
