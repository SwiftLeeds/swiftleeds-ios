//
//  String.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 06/08/2022.
//

import Foundation

extension String {
    var noEmojis: String {
        return self.unicodeScalars
            .filter { $0.properties.isEmojiPresentation == false }
            .reduce("") { $0 + String($1) }
    }
}
