import Foundation

extension String {
    var noEmojis: String {
        self.unicodeScalars
            .filter { $0.properties.isEmojiPresentation == false }
            .reduce("") { $0 + String($1) }
    }
}
