import DesignKit
import ReadabilityModifier
import SharedAssets
import SwiftUI

struct SponsorsView: View {
    @StateObject private var viewModel = SponsorsViewModel()
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var selectedSponsorLevel: SponsorLevel?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                FancyHeaderView(
                    title: "Sponsors",
                    foregroundImage: Image.swiftLeedsIcon
                )

                if isLoading {
                    loadingView
                        .padding(.top, Padding.screen)
                } else if viewModel.sections.isEmpty {
                    emptyStateView
                        .padding(.top, Padding.screen)
                } else {
                    sponsorsList
                }
            }
        }
        .background(Color.background, ignoresSafeAreaEdges: .all)
        .edgesIgnoringSafeArea(.top)
        .scrollIndicators(.hidden)
        .task {
            await loadSponsors()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: Padding.cellGap) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.accent)
            Text("Loading sponsors...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Padding.cellGap) {
            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No sponsors available")
                .font(.headline)
            Text("Check back later for updates")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding()
    }
    
    private var tierEmptyStateView: some View {
        VStack(spacing: Padding.cellGap) {
            if let selectedLevel = selectedSponsorLevel {
                Image(systemName: iconForLevel(selectedLevel))
                    .font(.system(size: 50))
                    .foregroundColor(.secondary.opacity(0.6))
                
                Text("No \(selectedLevel.rawValue.capitalized) Sponsors")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("This tier doesn't have any sponsors yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }
    
    private var sponsorsList: some View {
        VStack(spacing: Padding.cellGap) {
            filterChips
            
            if filteredSections.isEmpty && selectedSponsorLevel != nil {
                tierEmptyStateView
            } else {
                ForEach(filteredSections) { section in
                    sectionView(for: section)
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, Padding.cellGap)
    }
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All",
                    isSelected: selectedSponsorLevel == nil,
                    action: { selectedSponsorLevel = nil }
                )
                
                ForEach([SponsorLevel.platinum, .gold, .silver], id: \.self) { level in
                    FilterChip(
                        title: level.rawValue.capitalized,
                        isSelected: selectedSponsorLevel == level,
                        action: { 
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedSponsorLevel = level == selectedSponsorLevel ? nil : level
                            }
                        }
                    )
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var filteredSections: [SponsorsViewModel.Section] {
        if let selectedLevel = selectedSponsorLevel {
            return viewModel.sections.filter { $0.type == selectedLevel }
        }
        return viewModel.sections
    }
    
    private var gridColumns: [GridItem] {
        return Array(repeating: GridItem(.flexible(), spacing: Padding.cellGap), count: columnCount)
    }
    
    private var columnCount: Int {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2
        #else
        return 2
        #endif
    }
    
    private var horizontalPadding: CGFloat {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad ? Padding.screen * 2 : Padding.screen
        #else
        return Padding.screen
        #endif
    }
    
    private func sectionView(for section: SponsorsViewModel.Section) -> some View {
        VStack(alignment: .leading, spacing: Padding.stackGap) {
            sectionHeader(for: section.type)
            
            switch section.type {
            case .platinum:
                VStack(spacing: Padding.cellGap) {
                    ForEach(section.sponsors) { sponsor in
                        SponsorTileView(sponsor: sponsor)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                    }
                }
            case .gold, .silver:
                LazyVGrid(
                    columns: gridColumns,
                    alignment: .leading,
                    spacing: Padding.cellGap
                ) {
                    ForEach(section.sponsors) { sponsor in
                        SponsorTileView(sponsor: sponsor)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                    }
                }
            }
        }
        .padding(.bottom, Padding.cellGap)
    }
    
    private func sectionHeader(for sponsorLevel: SponsorLevel) -> some View {
        HStack {
            Image(systemName: iconForLevel(sponsorLevel))
                .font(.caption)
                .foregroundColor(colorForLevel(sponsorLevel))
            
            Text("\(sponsorLevel.rawValue.capitalized) Sponsors")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(sponsorCount(for: sponsorLevel))")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.1))
                .clipShape(Capsule())
        }
        .accessibilityAddTraits(.isHeader)
        .padding(.vertical, 8)
    }
    
    private func iconForLevel(_ level: SponsorLevel) -> String {
        switch level {
        case .platinum: return "crown.fill"
        case .gold: return "star.fill"
        case .silver: return "star"
        }
    }
    
    private func colorForLevel(_ level: SponsorLevel) -> Color {
        switch level {
        case .platinum: return .purple
        case .gold: return .yellow
        case .silver: return .gray
        }
    }
    
    private func sponsorCount(for level: SponsorLevel) -> Int {
        viewModel.sections.first { $0.type == level }?.sponsors.count ?? 0
    }
    
    private func loadSponsors() async {
        do {
            try await viewModel.loadSponsors()
            withAnimation(.easeInOut(duration: 0.3)) {
                isLoading = false
            }
        } catch {
            withAnimation(.easeInOut(duration: 0.3)) {
                isLoading = false
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accent : Color.secondary.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct SponsorsView_Previews: PreviewProvider {
    static var previews: some View {
        SponsorsView()
    }
}
