//
//  BottomSheetView.swift
//  SwiftLeeds
//
//  Created by LUCKY AGARWAL on 25/07/22.
//

import SwiftUI

struct BottomSheetView: View {
    @GestureState private var translation: CGFloat = 0
    @Binding var isOpen: Bool

    let categories: [Local.LocationCategory]
    let error: Error?
    
    let maxHeight: CGFloat
    let minHeight: CGFloat
    
    private var offsetY: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }
    
    internal init (
        isOpen: Binding<Bool>,
        categories: [Local.LocationCategory],
        error: Error?,
        maxHeight: CGFloat
    ){
        self.minHeight = maxHeight * Constants.minHeightRatio
        self.maxHeight = maxHeight
        self.categories = categories
        self.error = error
        self._isOpen = isOpen
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack(spacing: Padding.cellGap) {
                    Spacer()
                    SectionHeader(title: "Local",
                                  fontStyle: .title2.weight(.semibold),
                                  foregroundColor: .primary)
                    ScrollView {
                        ForEach(categories, id: \.self) { category in
                            LocalCell(
                                label: category.name,
                                imageName: category.symbolName,
                                labelFontStyle: .body
                            )
                        }
                    }
                    .padding(.bottom, Constant.tabBarPadding) // Account for the tab bar
                    .transition(.opacity)
                }
                .padding(Padding.screen)
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(Color.background)
            .cornerRadius(Constants.bottomSheetRadius)
            .frame(height: geometry.size.height, alignment: .bottom)
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

private extension BottomSheetView {
    struct Constant {
        static let tabBarPadding: CGFloat = UITabBar().frame.height
    }
}

struct BottomSheet_Previews: PreviewProvider {
    
    static var previews: some View {
        GeometryReader{ proxy in
            BottomSheetView(
                isOpen: .constant(true),
                categories: [
                    Local.LocationCategory(id: .init(), name: "Drinks", symbolName: "wineglass.fill", locations: [])
                ],
                error: nil,
                maxHeight: proxy.size.height * Constants.maxHeightRatio
            )
            .background(.blue)
            .previewDevice(PreviewDevice(rawValue: "iPhone 13"))
        }
        .edgesIgnoringSafeArea(.all)
    }
}
