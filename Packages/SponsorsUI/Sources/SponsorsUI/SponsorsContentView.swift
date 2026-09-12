import DesignKit
import SharedAssets
import SponsorsFeature
import SwiftUI
import UIComponents

/// The sponsors screen, drawn from a state it is given. It fetches nothing.
package struct SponsorsContentView: View {
    /// What the screen shows. A fetch that fails leaves it `empty`.
    package enum ScreenState: Equatable {
        case loading
        case empty
        case loaded(Sponsors)

        package init(_ sponsors: Sponsors) {
            self = sponsors.isEmpty ? .empty : .loaded(sponsors)
        }
    }

    private let state: ScreenState
    @State private var selectedLevel: SponsorLevel?

    package init(state: ScreenState) {
        self.state = state
    }

    package var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                FancyHeaderView(
                    title: "Sponsors",
                    foregroundImage: Image.swiftLeedsIcon
                )

                content
            }
        }
        .background(Color.background, ignoresSafeAreaEdges: .all)
        .edgesIgnoringSafeArea(.top)
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .loading:
            loadingView
                .padding(.top, Padding.screen)
        case .empty:
            emptyStateView
                .padding(.top, Padding.screen)
        case .loaded(let sponsors):
            sponsorsList(for: sponsors)
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
            if let selectedLevel {
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

    private func sponsorsList(for sponsors: Sponsors) -> some View {
        VStack(spacing: Padding.cellGap) {
            filterChips

            if displayedLevels(in: sponsors).isEmpty && selectedLevel != nil {
                tierEmptyStateView
            } else {
                ForEach(displayedLevels(in: sponsors), id: \.self) { level in
                    sectionView(for: level, in: sponsors)
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
                    isSelected: selectedLevel == nil,
                    action: { selectedLevel = nil }
                )

                ForEach(SponsorLevel.allCases, id: \.self) { level in
                    FilterChip(
                        title: level.rawValue.capitalized,
                        isSelected: selectedLevel == level,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedLevel = level == selectedLevel ? nil : level
                            }
                        }
                    )
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func displayedLevels(in sponsors: Sponsors) -> [SponsorLevel] {
        guard let selectedLevel else { return sponsors.rankedLevels }
        return sponsors.rankedLevels.filter { $0 == selectedLevel }
    }

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Padding.cellGap), count: columnCount)
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

    private func sectionView(for level: SponsorLevel, in sponsors: Sponsors) -> some View {
        VStack(alignment: .leading, spacing: Padding.stackGap) {
            sectionHeader(for: level, in: sponsors)

            switch level {
            case .platinum:
                VStack(spacing: Padding.cellGap) {
                    tiles(for: level, in: sponsors)
                }
            case .gold, .silver:
                LazyVGrid(
                    columns: gridColumns,
                    alignment: .leading,
                    spacing: Padding.cellGap
                ) {
                    tiles(for: level, in: sponsors)
                }
            }
        }
        .padding(.bottom, Padding.cellGap)
    }

    private func tiles(for level: SponsorLevel, in sponsors: Sponsors) -> some View {
        ForEach(sponsors.sponsors(at: level)) { sponsor in
            SponsorTileView(sponsor: sponsor)
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
        }
    }

    private func sectionHeader(for level: SponsorLevel, in sponsors: Sponsors) -> some View {
        HStack {
            Image(systemName: iconForLevel(level))
                .font(.caption)
                .foregroundColor(colorForLevel(level))

            Text("\(level.rawValue.capitalized) Sponsors")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)

            Spacer()

            Text("\(sponsors.sponsors(at: level).count)")
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
}
