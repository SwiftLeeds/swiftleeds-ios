//
//  MyConferenceView.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 14/11/2021.
//

import SwiftUI

struct MyConferenceView: View {
    @StateObject private var viewModel = MyConferenceViewModel()

    @State private var currentIndex: Int = 0
    @Namespace private var namespace
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Divider()

                if viewModel.slots.isEmpty {
                    empty
                } else {
                    schedule
                }

                Divider()
            }
            .background(Color.listBackground)
            .navigationTitle("Schedule")
            .accentColor(.white)
        }
        .task {
            try? await viewModel.loadSchedule()
        }
    }

    private var schedule: some View {
        VStack(spacing: 0) {
            ViewThatFits {
                scheduleHeaders

                ScrollView(.horizontal) {
                    scheduleHeaders
                }
            }

            TabView(selection: $currentIndex) {
                ForEach(Array(zip(viewModel.days.indices, viewModel.days)), id: \.0) { index, key in
                    ScheduleView(slots: viewModel.slots[key] ?? [], showSlido: viewModel.showSlido)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(.all)
        }
    }

    @ViewBuilder
    private var scheduleHeaders: some View {
        if viewModel.days.count == 1 {
            tabBarHeader(title: viewModel.days.first!, index: 0)
                .disabled(true)
                .padding()
        } else {
            HStack(spacing: 20) {
                ForEach(Array(zip(viewModel.days.indices, viewModel.days)), id: \.0) { index, key in
                    tabBarHeader(title: "Day \(index + 1)", index: index)
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }

    private func tabBarHeader(title: String, index: Int) -> some View {
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
    
    @ViewBuilder
    private var tickets: some View {
        if let numberOfDaysToConference = viewModel.numberOfDaysToConference {
            AnnouncementCell(label: "Get your ticket now!",
                             value: "\(numberOfDaysToConference) days",
                             valueIcon: "calendar.circle.fill",
                             gradientColors: [.accent, .accent])
            .previewDisplayName("Buy Ticket")
        }
    }
    
    private var empty: some View {
        VStack(spacing: 10) {
            Spacer()
            
            Image(systemName: "signpost.right.and.left")
                .font(.system(size: 60))
            
            Text("Come back soon")
                .font(.title)
            
            Text("We're working on filling this schedule")
                .font(.subheadline)
            
            Spacer()
        }
        .foregroundColor(.cellForeground)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Come back soon. We're working on filling this schedule")
    }
}

struct MyConferenceView_Previews: PreviewProvider {
    static var previews: some View {
        MyConferenceView()
    }
}
