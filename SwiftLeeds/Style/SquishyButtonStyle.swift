//
//  SquishyButtonStyle.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 01/07/2022.
//

import Foundation
import SwiftUI

 struct SquishyButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
