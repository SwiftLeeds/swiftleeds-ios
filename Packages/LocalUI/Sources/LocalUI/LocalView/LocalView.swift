#if canImport(UIKit)
import SwiftUI

/// The local screen: places near the venue, by category, on a map.
public struct LocalView: View {
    @State private var viewModel = ViewModel()

    public init() {}

    public var body: some View {
        LocalContentView(state: viewModel.state, reload: reload)
            .task {
                await viewModel.loadIfNeeded()
            }
    }

    private func reload() {
        Task(priority: .userInitiated) {
            await viewModel.load()
        }
    }
}

struct LocalView_Previews: PreviewProvider {
    static var previews: some View {
        LocalView()
    }
}
#endif
