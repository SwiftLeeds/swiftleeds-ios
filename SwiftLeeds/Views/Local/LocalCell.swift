//
//  LocalCell.swift
//  SwiftLeeds
//
//  Created by LUCKY AGARWAL on 25/07/22.
//

import SwiftUI

struct LocalCell: View {
    let label: String
    let imageName: String
    let foregroundColor: Color
    let labelFontStyle: Font
    
    internal init(label : String,
                  imageName: String,
                  foregroundColor: Color = .black,
                  labelFontStyle: Font = .headline.weight(.medium)
                  ){
        self.label = label
        self.imageName = imageName
        self.foregroundColor = foregroundColor
        self.labelFontStyle = labelFontStyle
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(labelFontStyle)
            Spacer()
            Image(imageName)
        }
        .padding(Padding.cell)
        .frame(minHeight: Constants.cellMinimumHeight)
        .background {
            RoundedRectangle(cornerRadius: Constants.cellRadius).fill(.white)
        }
    }
}

struct LocalCell_Previews: PreviewProvider {
    static var previews: some View {
        LocalCell(label: "Food", imageName: "")
    }
        
}
