#if canImport(UIKit)
import SwiftUI

/// The schedule screen. It fetches the schedule when it appears.
public struct ScheduleView: View {
    @State private var viewModel = ViewModel()

    public init() {}

    public var body: some View {
        ScheduleContentView(
            state: viewModel.state,
            events: viewModel.events,
            currentEvent: viewModel.currentEvent,
            selectEvent: { event in
                Task { await viewModel.select(event) }
            },
            retry: {
                Task { await viewModel.retry() }
            }
        )
        .task {
            await viewModel.load()
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
    }
}
#endif
