#if canImport(UIKit)
import CoreLocation
import DesignKit
import LocalFeature
import MapKit
import SwiftUI
import UIAssets

/// The local screen, drawn from a state it is given. It fetches nothing.
package struct LocalContentView: View {
    /// What the screen shows.
    package enum ScreenState: Equatable, Hashable, Sendable {
        case loading

        /// Each category has at least one place.
        case loaded([LocationCategory])

        case failed
    }

    private let state: ScreenState
    private let reload: () -> Void

    @State private var bottomSheetShown = true
    @State private var mapRegion = MKCoordinateRegion.aroundVenue
    @State private var selectedCategoryID: LocationCategoryID?
    @State private var selectedLocation: Location?

    /// Whether VoiceOver focus sits on the location card.
    @AccessibilityFocusState private var isLocationCardFocused: Bool

    /// The map annotation VoiceOver focus should return to on dismissal.
    @AccessibilityFocusState private var focusedAnnotationID: LocationID?

    /// Creates the screen.
    ///
    /// - Parameters:
    ///   - state: What the screen shows.
    ///   - reload: Called when the person taps Reload on the error overlay.
    package init(state: ScreenState, reload: @escaping () -> Void) {
        self.state = state
        self.reload = reload
    }

    package var body: some View {
        if state == .failed {
            errorView
        } else {
            mapAndSheet
        }
    }

    private var mapAndSheet: some View {
        ZStack {
            GeometryReader { geometry in
                if let category = shownCategory {
                    Map(
                        coordinateRegion: $mapRegion,
                        annotationItems: category.locations,
                    ) { location in
                        MapAnnotation(
                            coordinate: CLLocationCoordinate2D(
                                latitude: location.coordinate.latitude,
                                longitude: location.coordinate.longitude,
                            )
                        ) {
                            Button {
                                selectedLocation = location
                            } label: {
                                symbolImage(named: category.symbolName)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(.white)
                                    )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(Text(verbatim: location.name))
                            .accessibilityFocused($focusedAnnotationID, equals: location.id)
                        }
                    }
                    .ignoresSafeArea()
                }

                if let location = selectedLocation, let category = shownCategory {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea(.all)
                            .accessibilityHidden(true)
                            .onTapGesture {
                                selectedLocation = nil
                            }

                        LocationCard(
                            symbolName: category.symbolName,
                            name: location.name,
                            websiteURL: location.websiteURL,
                            dismiss: { selectedLocation = nil },
                        )
                        .padding(.bottom, bottomSheetShown ? geometry.size.height * Constants.maxHeightRatio : 0)
                        .animation(.easeInOut, value: bottomSheetShown)
                        .accessibilityFocused($isLocationCardFocused)
                    }
                }

                BottomSheetView(
                    isOpen: $bottomSheetShown,
                    selectedCategory: Binding(
                        get: { shownCategory },
                        set: { selectedCategoryID = $0?.id },
                    ),
                    categories: categories,
                    maxHeight: geometry.size.height * Constants.maxHeightRatio,
                )
            }
        }
        .onChange(of: selectedLocation) { previousLocation, newLocation in
            if newLocation != nil {
                isLocationCardFocused = true
            } else if let previousLocation {
                focusedAnnotationID = previousLocation.id
            }
        }
    }

    private var categories: [LocationCategory] {
        guard case .loaded(let categories) = state else { return [] }
        return categories
    }

    // Until the person selects a category, or when the list no longer holds it, the first one.
    private var shownCategory: LocationCategory? {
        categories.first { $0.id == selectedCategoryID } ?? categories.first
    }

    private var errorView: some View {
        ContentUnavailableView {
            Label {
                Text(verbatim: "Something has gone wrong")
            } icon: {
                Image(systemName: "exclamationmark.triangle")
            }
        } description: {
            Text(verbatim: "Please try again later.")
        } actions: {
            Button(action: reload) {
                Text(verbatim: "Reload")
            }
        }
        .background(Color.background, ignoresSafeAreaEdges: .all)
    }
}

extension MKCoordinateRegion {
    // Leeds Playhouse, where both SwiftLeeds and KotlinLeeds take place.
    fileprivate static let aroundVenue = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.7981911, longitude: -1.53507),
        span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04),
    )
}
#endif
