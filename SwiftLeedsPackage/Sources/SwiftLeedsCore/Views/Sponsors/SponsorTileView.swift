//
//  SponsorTileView.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 01/07/2022.
//

import SwiftUI
import CachedAsyncImage

struct SponsorTileView: View {
    let sponsor: Sponsor
    @State private var showingJobs = false
    @State private var isImageLoaded = false
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            mainTile
            
            if !sponsor.jobs.isEmpty {
                jobsSection
            }
        }
        .background(Color.cellBackground, in: contentShape)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cellRadius, style: .continuous)
                .stroke(Color.accent.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var mainTile: some View {
        Button(action: { 
            if let url = URL(string: sponsor.url) {
                openURL(url)
            }
        }) {
            VStack(alignment: .leading, spacing: 0) {
                imageSection
                infoSection
            }
        }
        .buttonStyle(SquishyButtonStyle())
    }
    
    private var imageSection: some View {
        ZStack {
            CachedAsyncImage(
                url: URL(string: sponsor.image),
                content: { image in
                    Rectangle()
                        .aspectRatio(1.66, contentMode: .fill)
                        .foregroundColor(.clear)
                        .background(
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .transition(.opacity)
                                .onAppear { 
                                    withAnimation(.easeIn(duration: 0.3)) {
                                        isImageLoaded = true
                                    }
                                }
                        )
                        .background(
                            LinearGradient(
                                colors: [Color.cellBackground, Color.cellBackground.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipped()
                },
                placeholder: {
                    Rectangle()
                        .foregroundColor(.cellBackground)
                        .overlay(
                            ShimmerView()
                        )
                }
            )
            .aspectRatio(1.66, contentMode: .fit)
            .accessibilityHidden(true)
            
            if sponsor.sponsorLevel == .platinum {
                VStack {
                    HStack {
                        Spacer()
                        Label("Platinum", systemImage: "crown.fill")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.purple, .purple.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .padding(8)
                    }
                    Spacer()
                }
            }
        }
        .padding(16)
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(sponsor.name)
                        .foregroundColor(.primary)
                        .font(.headline.weight(.semibold))
                        .lineLimit(1)
                    
                    if !sponsor.subtitle.isEmpty {
                        Text(sponsor.subtitle)
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.title3)
                    .foregroundColor(.accent.opacity(0.7))
            }
            
            if !sponsor.jobs.isEmpty {
                HStack {
                    Label("\(sponsor.jobs.count) Job\(sponsor.jobs.count > 1 ? "s" : "")", systemImage: "briefcase.fill")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.accent)
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Sponsor, \(sponsor.name), \(sponsor.subtitle). \(sponsor.jobs.isEmpty ? "" : "\(sponsor.jobs.count) job opportunities available")")
    }
    
    private var jobsSection: some View {
        VStack(spacing: 0) {
            Divider()
            
            Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { showingJobs.toggle() } }) {
                HStack {
                    Text("Job Opportunities")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: showingJobs ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.accent.opacity(0.05))
            }
            
            if showingJobs {
                VStack(spacing: 0) {
                    ForEach(sponsor.jobs) { job in
                        JobRowView(job: job)
                    }
                }
                .transition(.asymmetric(
                    insertion: .push(from: .top).combined(with: .opacity),
                    removal: .push(from: .bottom).combined(with: .opacity)
                ))
            }
        }
    }
    
    private var contentShape: some Shape {
        RoundedRectangle(cornerRadius: Constants.cellRadius, style: .continuous)
    }
}

struct JobRowView: View {
    let job: Job
    @Environment(\.openURL) private var openURL
    @State private var isPressed = false
    
    var body: some View {
        Button(action: { 
            if let url = URL(string: job.url) {
                openURL(url)
            }
        }) {
            VStack(spacing: 0) {
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(job.title)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                            Text(job.location)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle")
                        .font(.title3)
                        .foregroundColor(.accent.opacity(0.5))
                }
                .padding()
                .background(isPressed ? Color.accent.opacity(0.05) : Color.clear)
            }
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}


struct SponsorTileView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            
            VStack {
                SponsorTileView(sponsor: .sample)
                    .padding()
            }
        }
    }
}
