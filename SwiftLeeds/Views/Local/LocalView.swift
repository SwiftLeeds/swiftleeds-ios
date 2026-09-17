import DesignKit
import LocalFeature
import MapKit
import SharedAssets
import SwiftUI

struct LocalView: View {
    @StateObject private var model = LocalViewModel()

    @State private var bottomSheetShown = true
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.78613099154973, longitude: -1.5461652186147719),
        span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
    )
    @State private var selectedLocation: Location?

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                if let category = model.selectedCategory {
                    Map(
                        coordinateRegion: $mapRegion,
                        showsUserLocation: true,
                        annotationItems: model.selectedLocations
                    ) { location in
                        MapAnnotation(coordinate: CLLocationCoordinate2D(
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
                        )) {
                            symbolImage(named: category.symbolName)
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(.white)
                                )
                                .onTapGesture {
                                    selectedLocation = location

                                }
                        }
                    }
                    .ignoresSafeArea()
                }

                if let location = selectedLocation, let category = model.selectedCategory {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea(.all)
                            .onTapGesture {
                                selectedLocation = nil
                            }

                        locationInfoView(category: category, location: location)
                            .padding(.bottom, bottomSheetShown ? geometry.size.height * Constants.maxHeightRatio: 0)
                            .animation(.easeInOut, value: bottomSheetShown)
                    }
                }

                BottomSheetView(
                    isOpen: $bottomSheetShown,
                    selectedCategory: $model.selectedCategory,
                    categories: model.categories,
                    maxHeight: geometry.size.height * Constants.maxHeightRatio
                )

                if model.error != nil {
                    errorView
                }
            }
        }
    }

    var errorView: some View {
        Rectangle()
            .foregroundStyle(.ultraThinMaterial)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack(alignment: .center, spacing: Padding.stackGap) {
                    Text(verbatim: "Something has gone wrong. Please try again later.")
                        .font(.subheadline.weight(.medium))
                        .multilineTextAlignment(.center)
                    Button {
                        reload()
                    } label: {
                        Text(verbatim: "Reload")
                    }
                }
                .padding()
            )
    }

    private func reload() {
        Task(priority: .userInitiated) {
            await model.loadData()
        }
    }

    private func symbolImage(named name: String) -> Image {
        Image(uiImage: UIImage(systemName: name) ?? UIImage(imageLiteralResourceName: name))
    }

    private func locationInfoView(category: LocationCategory, location: Location) -> some View {
        VStack(spacing: 10) {
            symbolImage(named: category.symbolName)
                .renderingMode(.template)
                .frame(width: 44, height: 44)

            Text(location.name)

            Button {
                UIApplication.shared.open(location.websiteURL)
            } label: {
                Text(verbatim: "View More")
                    .bold()
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.accent)
                    .background(Color.accent.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(10)
        .padding(.bottom, 5)
        .frame(width: 200)
        .foregroundColor(Color.cellForeground)
        .background(Color.cellBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct LocalView_Previews: PreviewProvider {
    static var previews: some View {
        LocalView()
    }
}
