//
//  SectionHeader.swift
//  SwiftLeeds
//
//  Created by LUCKY AGARWAL on 23/07/22.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    let fontStyle: Font
    let foregroundColor: Color
    let maxWidth: CGFloat
    let alignment: Alignment
    let accesibilityAddTraits: AccessibilityTraits
    
    internal init(title: String,
                  fontStyle: Font = .callout.weight(.semibold),
                  foregroundColor : Color = .secondary,
                  maxWidth: CGFloat = .infinity,
                  alignment: Alignment = .leading,
                  accessbilityAddTraits: AccessibilityTraits = .isHeader
    ) {
        self.title = title
        self.fontStyle = fontStyle
        self.foregroundColor = foregroundColor
        self.maxWidth = maxWidth
        self.alignment = alignment
        self.accesibilityAddTraits = accessbilityAddTraits
    }
    
    var body: some View {
        Text(title)
            .font(fontStyle)
            .foregroundColor(foregroundColor)
            .frame(maxWidth: maxWidth, alignment: alignment)
            .accessibilityAddTraits(accesibilityAddTraits)
    }
}

struct SectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeader(title: "SwiftLeeds")
    }
}
