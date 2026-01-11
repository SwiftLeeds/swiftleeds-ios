import Foundation

extension String {
    var noEmojis: String {
        return self.unicodeScalars
            .filter { !$0.properties.isEmojiPresentation }
            .reduce("") { $0 + String($1) }
    }
}
