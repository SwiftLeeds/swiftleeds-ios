extension String {
    var noEmojis: String {
        self.unicodeScalars
            .filter { $0.properties.isEmojiPresentation == false }
            .reduce(into: "") { $0 += String($1) }
    }
}
