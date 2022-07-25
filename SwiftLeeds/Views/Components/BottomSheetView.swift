//
//  BottomSheetView.swift
//  SwiftLeeds
//
//  Created by LUCKY AGARWAL on 25/07/22.
//

import SwiftUI

struct BottomSheetView: View {
    var body: some View {
        VStack{
            ScrollView {
                VStack(spacing: Padding.cellGap) {
                    Spacer()
                    SectionHeader(title: "Local",fontStyle: .title2.weight(.semibold) , foregroundColor: .primary)
                    LocalCell(label: "Food", imageName: "", labelFontStyle: .body)
                    LocalCell(label: "Coffee", imageName: "", labelFontStyle: .body)
                    LocalCell(label: "Drink", imageName: "", labelFontStyle: .body)
                    LocalCell(label: "Best of Leeds", imageName: "", labelFontStyle: .body)
                    
                }
                .padding(Padding.screen)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.init(UIColor(.tabBarBackground)))
        .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .ignoresSafeArea(edges: .bottom)
    }
}

struct BottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheetView()
            .background(.blue)
    }
}
