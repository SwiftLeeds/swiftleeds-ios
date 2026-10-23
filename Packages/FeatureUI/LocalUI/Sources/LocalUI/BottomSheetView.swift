#if canImport(UIKit)
import Foundation
import LocalFeature
import ReadabilityModifier
import SwiftUI
import UIAssets
import UIComponents

/// The sheet that lists the categories and marks the selected one. Drag it to open or close it.
package struct BottomSheetView: View {
    @Binding var isOpen: Bool
    @Binding var selectedCategory: LocationCategory?

    @GestureState private var translation: CGFloat = 0

    private let categories: [LocationCategory]

    private let maxHeight: CGFloat
    private let minHeight: CGFloat

    private var offsetY: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }

    /// Creates the sheet.
    ///
    /// - Parameters:
    ///   - isOpen: Whether the sheet shows at its full height.
    ///   - selectedCategory: The selected category. Tapping a row sets it.
    ///   - categories: The categories to list, in order.
    ///   - maxHeight: The sheet's height when open.
    package init(
        isOpen: Binding<Bool>,
        selectedCategory: Binding<LocationCategory?>,
        categories: [LocationCategory],
        maxHeight: CGFloat,
    ) {
        self.minHeight = maxHeight * Constants.minHeightRatio
        self.maxHeight = maxHeight
        self.categories = categories
        self._isOpen = isOpen
        self._selectedCategory = selectedCategory
    }

    package var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack(spacing: Padding.cellGap) {
                    Spacer()
                    SectionHeader(
                        title: "Local",
                        fontStyle: .title2.weight(.semibold),
                        foregroundColor: .primary,
                    )
                    .fitToReadableContentGuide(type: .width)
                    ScrollView {
                        ForEach(categories) { category in
                            LocalCell(
                                label: category.name,
                                imageName: category.symbolName,
                                foregroundColor: (category == selectedCategory ? .accent : .cellForeground),
                                labelFontStyle: .body,
                            ) {
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
            .frame(width: geometry.size.width, height: maxHeight, alignment: .top)
            .background(Color.background)
            .cornerRadius(Constants.bottomSheetRadius)
            .frame(height: geometry.size.height + Padding.screen, alignment: .bottom)
            .offset(y: max(offsetY + translation, 0))
            .animation(.interactiveSpring(), value: isOpen)
            .animation(.interactiveSpring(), value: translation)
            .gesture(
                DragGesture().updating($translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    let snapDistance = maxHeight * Constants.snapRatio
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                    isOpen = value.translation.height < 0
                }
            )
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

#if DEBUG
#Preview {
    if let items = try? items {
        sheet(items)
    } else {
        Text(verbatim: "The preview's locations could not be built.")
    }
}

/// Returns the sheet, open and sized to the screen, over a blue background.
///
/// - Parameter items: The categories the sheet lists. The first one is selected.
/// - Returns: A view that shows the sheet.
@MainActor
private func sheet(_ items: [LocationCategory]) -> some View {
    GeometryReader { proxy in
        BottomSheetView(
            isOpen: .constant(true),
            selectedCategory: .constant(items.first),
            categories: items,
            maxHeight: proxy.size.height * Constants.maxHeightRatio,
        )
        .background(.blue)
    }
    .edgesIgnoringSafeArea(.all)
}

/// The categories the preview lists.
private var items: [LocationCategory] {
    get throws {
        [
            category(
                "Food",
                symbolName: "takeoutbag.and.cup.and.straw.fill",
                location: location(
                    "Trinity Kitchen",
                    link: "https://trinityleeds.com/shops/trinity-kitchen",
                    coordinate: try Coordinate(latitude: 53.797378, longitude: -1.545209),
                ),
            ),
            category(
                "Drinks",
                symbolName: "wineglass.fill",
                location: location(
                    "Brew Society",
                    link: "https://www.brewsociety.co.uk/",
                    coordinate: try Coordinate(latitude: 53.79584058588689, longitude: -1.550339186509128),
                ),
            ),
        ]
    }
}

/// Returns a category that holds one location.
///
/// - Parameters:
///   - name: The category's name.
///   - symbolName: The name of the SF Symbol that marks the category.
///   - location: The category's only location.
/// - Returns: The category.
private func category(_ name: String, symbolName: String, location: Location) -> LocationCategory {
    LocationCategory(id: LocationCategoryID(UUID()), name: name, symbolName: symbolName, locations: [location])
}

/// Returns a location with a website and a coordinate.
///
/// - Parameters:
///   - name: The location's name.
///   - link: The address of the location's website.
///   - coordinate: Where the location is.
/// - Returns: The location.
private func location(_ name: String, link: String, coordinate: Coordinate) -> Location {
    Location(id: LocationID(UUID()), name: name, websiteURL: URL(string: link), coordinate: coordinate)
}
#endif
#endif
