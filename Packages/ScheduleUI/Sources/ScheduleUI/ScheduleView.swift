#if canImport(UIKit)
import ScheduleFeature
import SwiftUI

/// The conference schedule. Fetches it, then hands it to the view that draws it.
public struct ScheduleView: View {
    @StateObject private var viewModel = ScheduleViewModel()

    public init() {}

    public var body: some View {
        ScheduleContentView(
            state: viewModel.state,
            events: viewModel.events,
            currentEvent: viewModel.currentEvent,
            selectEvent: { event in
                Task { await viewModel.select(event) }
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
