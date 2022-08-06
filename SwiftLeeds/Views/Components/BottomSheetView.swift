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
    
    let maxHeight: CGFloat
    let minHeight: CGFloat
    
    private var offsetY: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }
    
    internal init (isOpen: Binding<Bool>,
                   maxHeight: CGFloat){
        self.minHeight = maxHeight * Constants.minHeightRatio
        self.maxHeight = maxHeight
        self._isOpen = isOpen
    }
    
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                VStack(spacing: Padding.cellGap) {
                    Spacer()
                    SectionHeader(title: "Local",
                                  fontStyle: .title2.weight(.semibold),
                                  foregroundColor: .primary)
                    ScrollView {
                        LocalCell(label: "Food",
                                  imageName:"takeoutbag.and.cup.and.straw.fill",
                                  labelFontStyle: .body)
                        LocalCell(label: "Coffee",
                                  imageName: "cup.and.saucer.fill",
                                  labelFontStyle: .body)
                        LocalCell(label: "Drink",
                                  imageName: "wineglass.fill" ,
                                  labelFontStyle: .body)
                        LocalCell(label: "Best of Leeds",
                                  imageName: "mappin",
                                  labelFontStyle: .body)
                    }
                }
                .padding(Padding.screen)
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(Color(.secondarySystemBackground))
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


struct BottomSheet_Previews: PreviewProvider {
    
    static var previews: some View {
        GeometryReader{ proxy in
            BottomSheetView(isOpen: .constant(true), maxHeight: proxy.size.height * Constants.maxHeightRatio)
                .background(.blue)
                .previewDevice(PreviewDevice(rawValue: "iPhone 13"))
        }
        .edgesIgnoringSafeArea(.all)
    }
}
