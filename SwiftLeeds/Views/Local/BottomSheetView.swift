import DesignKit
import MapKit
import ReadabilityModifier
import SharedAssets
import SwiftUI

struct BottomSheetView: View {
    @Binding var isOpen: Bool
    @Binding var selectedCategory: Local.LocationCategory?

    @GestureState private var translation: CGFloat = 0

    private let categories: [Local.LocationCategory]
    private let error: Error?
    
    private let maxHeight: CGFloat
    private let minHeight: CGFloat
    
    private var offsetY: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }
    
    init (
        isOpen: Binding<Bool>,
        selectedCategory: Binding<Local.LocationCategory?>,
        categories: [Local.LocationCategory],
        error: Error?,
        maxHeight: CGFloat
    ){
        self.minHeight = maxHeight * Constants.minHeightRatio
        self.maxHeight = maxHeight
        self.categories = categories.filter { $0.locations.isEmpty == false }
        self.error = error
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
    static let items: [Local.LocationCategory] = [
        Local.LocationCategory(
            id: UUID(),
            name: "Food",
            symbolName: "takeoutbag.and.cup.and.straw.fill",
            locations: [
                Local.Location(
                    id: UUID(),
                    name: "Trinity Kitchen",
                    url: URL(string: "https://trinityleeds.com/shops/trinity-kitchen")!,
                    location: CLLocation(
                        latitude: 53.797378,
                        longitude: -1.545209
                    )
                )
            ]
        ),
        Local.LocationCategory(
            id: UUID(),
            name: "Drinks",
            symbolName: "wineglass.fill",
            locations: [
                Local.Location(
                    id: UUID(),
                    name: "Brew Society",
                    url: URL(string: "https://www.brewsociety.co.uk/")!,
                    location: CLLocation(
                        latitude: 53.79584058588689,
                        longitude: -1.550339186509128
                    )
                )
            ]
        ),
    ]

    static var previews: some View {
        GeometryReader{ proxy in
            BottomSheetView(
                isOpen: .constant(true),
                selectedCategory: .constant(Self.items.first),
                categories: Self.items,
                error: nil,
                maxHeight: proxy.size.height * Constants.maxHeightRatio
            )
            .background(.blue)
            .previewDevice(PreviewDevice(rawValue: "iPhone 13"))
        }
        .edgesIgnoringSafeArea(.all)
    }
}
