//
//  CommonCompo.swift
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
    
    internal init(_title: String,
                  _fontStyle: Font = .callout.weight(.semibold),
                  _foregroundColor : Color = .secondary,
                  _maxWidth: CGFloat = .infinity,
                  _alignment: Alignment = .leading,
                  _accessbilityAddTraits: AccessibilityTraits = .isHeader
    ) {
        title = _title
        fontStyle = _fontStyle
        foregroundColor = _foregroundColor
        maxWidth = _maxWidth
        alignment = _alignment
        accesibilityAddTraits = _accessbilityAddTraits
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
        SectionHeader(_title: "SwiftLeeds")
    }
}
