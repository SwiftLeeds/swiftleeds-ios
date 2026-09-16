#if canImport(UIKit)
import ScheduleFeature
import SharedAssets
import SwiftUI

/// The schedule screen, drawn from a state it is given. It fetches nothing.
package struct ScheduleContentView: View {
    package enum ScreenState {
        case loading
        case loaded(days: [Schedule.Day], showSlido: Bool)
        /// Names the conference that could not be loaded, when one was asked for by name.
        case failed(conference: String?, reason: ScheduleFetchError)
    }

    private let state: ScreenState
    private let events: [Schedule.Event]
    private let currentEvent: Schedule.Event?
    private let selectEvent: (Schedule.Event) -> Void
    private let retry: () -> Void

    @State private var currentIndex: Int = 0
    @Namespace private var namespace

    package init(
        state: ScreenState,
        events: [Schedule.Event] = [],
        currentEvent: Schedule.Event? = nil,
        selectEvent: @escaping (Schedule.Event) -> Void = { _ in },
        retry: @escaping () -> Void = {}
    ) {
        self.state = state
        self.events = events
        self.currentEvent = currentEvent
        self.selectEvent = selectEvent
        self.retry = retry
    }

    package var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                content
                Divider()
            }
            .background(Color.listBackground)
            .navigationTitle("Schedule")
            .toolbar { conferencePicker }
        }
        .accentColor(.white)
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .loading:
            loadingView
        case let .loaded(days, showSlido):
            schedule(days: days, showSlido: showSlido)
        case let .failed(conference, reason):
            failureView(for: conference, reason: reason)
        }
    }

    private var loadingView: some View {
        ZStack {
            Color.clear

            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(2)
        }
    }

    private func failureView(for conference: String?, reason: ScheduleFetchError) -> some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 10) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 60))

                Text(conference.map { "Can't show \($0)" } ?? "Can't show the schedule")
                    .font(.title)
                    .multilineTextAlignment(.center)

                Text(advice(for: reason))
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            .accessibilityElement(children: .combine)

            Button("Try Again", action: retry)
                .buttonStyle(.bordered)

            Spacer()
        }
        .padding(.horizontal)
        .foregroundColor(.cellForeground)
    }

    private func advice(for reason: ScheduleFetchError) -> String {
        switch reason {
        case .couldNotReachServer:
            "Check your connection and try again"
        case .invalidResponse:
            "Something went wrong on our side. Try again later"
        case .unknown:
            "Something went wrong on our side. Try again later"
        }
    }

    @ToolbarContentBuilder
    private var conferencePicker: some ToolbarContent {
        if let currentEvent, events.count > 1 {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    ForEach(events) { event in
                        Button {
                            selectEvent(event)
                        } label: {
                            Text(event.name)
                        }
                    }
                } label: {
                    HStack {
                        Text(currentEvent.name)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                    }
                }
                .accentColor(Color("AccentColor"))
            }
        }
    }

    private func schedule(days: [Schedule.Day], showSlido: Bool) -> some View {
        VStack(spacing: 0) {
            ViewThatFits {
                dayHeaders(for: days)
                ScrollView(.horizontal) {
                    dayHeaders(for: days)
                }
            }

            TabView(selection: $currentIndex) {
                ForEach(Array(zip(days.indices, days)), id: \.0) { index, day in
                    DayView(slots: day.slots, showSlido: showSlido)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(.all)
        }
    }

    @ViewBuilder
    private func dayHeaders(for days: [Schedule.Day]) -> some View {
        if days.count > 1 {
            HStack(spacing: 20) {
                ForEach(Array(zip(days.indices, days)), id: \.0) { index, day in
                    // Use the actual day names from the API
                    dayHeader(title: day.name, index: index)
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }

    private func dayHeader(title: String, index: Int) -> some View {
        Button {
            currentIndex = index
        } label: {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .light, design: .default))

                Text("")
                    .frame(height: 2)
            }
            .foregroundColor(.cellForeground)
            .overlay(alignment: .bottom) {
                if currentIndex == index {
                    Color.cellForeground
                        .frame(height: 2)
                        .matchedGeometryEffect(id: "tabSelectionLine", in: namespace, properties: .frame)
                } else {
                    Color.clear.frame(height: 2)
                }
            }
            .animation(.spring(), value: currentIndex)
        }
        .buttonStyle(.plain)
    }
}
#endif
