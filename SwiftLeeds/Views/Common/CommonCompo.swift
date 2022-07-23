//
//  CommonCompo.swift
//  SwiftLeeds
//
//  Created by LUCKY AGARWAL on 23/07/22.
//

import Foundation
import SwiftUI

class CommonCompo {
    
    static func sectionHeader(text: String) -> some View {
        Text(text)
            .font(.callout.weight(.semibold))
            .foregroundColor(.secondary)
            .frame(maxWidth:.infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
    
}
