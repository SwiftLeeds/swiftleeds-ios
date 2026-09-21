#if canImport(UIKit)
import DesignKit
import LocalFeature
import ReadabilityModifier
import SharedAssets
import SwiftUI

struct BottomSheetView: View {
    @Binding var isOpen: Bool
    @Binding var selectedCategory: LocationCategory?

    @GestureState private var translation: CGFloat = 0

    private let categories: [LocationCategory]

    private let maxHeight: CGFloat
    private let minHeight: CGFloat

    private var offsetY: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }

    init(
        isOpen: Binding<Bool>,
        selectedCategory: Binding<LocationCategory?>,
        categories: [LocationCategory],
        maxHeight: CGFloat
    ) {
        self.minHeight = maxHeight * Constants.minHeightRatio
        self.maxHeight = maxHeight
        self.categories = categories
        self._isOpen = isOpen
        self._selectedCategory = selectedCategory
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack(spacing: Padding.cellGap) {
                    Spacer()
                    SectionHeader(
                        title: "Local",
                        fontStyle: .title2.weight(.semibold),
                        foregroundColor: .primary
                    )
                    .fitToReadableContentGuide(type: .width)
                    ScrollView {
                        ForEach(categories) { category in
                            LocalCell(
                                label: category.name,
                                imageName: category.symbolName,
                                foregroundColor: (category == selectedCategory ? .accent : .cellForeground),
                                labelFontStyle: .body) {
                                    selectedCategory = category
                                }
                        }
                        .padding(.bottom, Padding.screen)
                    }
                    .fitToReadableContentGuide(type: .width)
                    .transition(.opacity)
                }
                .padding(Padding.screen)
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(Color.background)
            .cornerRadius(Constants.bottomSheetRadius)
            .frame(height: geometry.size.height + Padding.screen, alignment: .bottom)
            .offset(y: max(self.offsetY + self.translation, 0))
            .animation(.interactiveSpring(), value: isOpen)
            .animation(.interactiveSpring(), value: translation)
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    let snapDistance = self.maxHeight * Constants.snapRatio
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                    self.isOpen = value.translation.height < 0
                }
            )
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct BottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        if let items = try? items {
            preview(items)
        } else {
            Text(verbatim: "The preview's locations could not be built.")
        }
    }

    private static func preview(_ items: [LocationCategory]) -> some View {
        GeometryReader { proxy in
            BottomSheetView(
                isOpen: .constant(true),
                selectedCategory: .constant(items.first),
                categories: items,
                maxHeight: proxy.size.height * Constants.maxHeightRatio
            )
            .background(.blue)
            .previewDevice(PreviewDevice(rawValue: "iPhone 13"))
        }
        .edgesIgnoringSafeArea(.all)
    }

    private static var items: [LocationCategory] {
        get throws {
            [
                category(
                    "Food",
                    symbolName: "takeoutbag.and.cup.and.straw.fill",
                    location: try location(
                        "Trinity Kitchen",
                        link: "https://trinityleeds.com/shops/trinity-kitchen",
                        coordinate: try Coordinate(latitude: 53.797378, longitude: -1.545209)
                    )
                ),
                category(
                    "Drinks",
                    symbolName: "wineglass.fill",
                    location: try location(
                        "Brew Society",
                        link: "https://www.brewsociety.co.uk/",
                        coordinate: try Coordinate(latitude: 53.79584058588689, longitude: -1.550339186509128)
                    )
                ),
            ]
        }
    }

    private static func category(_ name: String, symbolName: String, location: Location) -> LocationCategory {
        LocationCategory(id: LocationCategoryID(UUID()), name: name, symbolName: symbolName, locations: [location])
    }

    private static func location(_ name: String, link: String, coordinate: Coordinate) throws -> Location {
        guard let websiteURL = URL(string: link) else { throw URLError(.badURL) }
        return Location(id: LocationID(UUID()), name: name, websiteURL: websiteURL, coordinate: coordinate)
    }
}
#endif
