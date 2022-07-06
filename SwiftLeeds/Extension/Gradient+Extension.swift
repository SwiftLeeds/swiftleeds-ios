//
//  Gradient+Extension.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 05/07/2022.
//

import Foundation
import SwiftUI

extension LinearGradient {
    static let weather = LinearGradient(colors: [
        .weatherGradientStart, .weatherGradientEnd
    ], startPoint: .bottomLeading, endPoint: .topLeading)

    static let announcement = LinearGradient(colors: [
        .buyTicketGradientStart, .buyTicketGradientEnd
    ], startPoint: .bottomLeading, endPoint: .topLeading)

    static let callout = LinearGradient(colors: [
        .nextTalkGradientStart, .nextTalkGradientEnd
    ], startPoint: .bottomLeading, endPoint: .topLeading)
}
