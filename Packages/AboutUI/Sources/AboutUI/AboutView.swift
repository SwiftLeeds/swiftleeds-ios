#if canImport(UIKit)
import SharedAssets
import SwiftUI

/// The About screen: the conference's story, its links, and the team.
public struct AboutView: View {
    @State private var viewModel = AboutViewModel()

    public init() {}

    public var body: some View {
        ScrollView {
            AboutContentView(viewModel: viewModel)
        }
        .background(Color.background, ignoresSafeAreaEdges: .all)
        .edgesIgnoringSafeArea(.top)
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
