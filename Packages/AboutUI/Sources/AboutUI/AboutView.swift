#if canImport(UIKit)
import SwiftUI

/// The About screen: the conference's story, its links, and the team.
public struct AboutView: View {
    @State private var viewModel = AboutViewModel()

    public init() {}

    public var body: some View {
        AboutContentView(viewModel: viewModel)
            .task {
                await viewModel.loadIfNeeded()
            }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .preferredColorScheme(.dark)
    }
}
#endif
