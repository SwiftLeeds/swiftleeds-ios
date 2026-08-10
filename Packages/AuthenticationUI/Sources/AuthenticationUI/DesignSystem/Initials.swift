import Foundation

package enum Initials {
    package static func from(_ name: PersonNameComponents) -> String {
        name.formatted(.name(style: .abbreviated))
    }

    package static func from(_ name: String) -> String {
        let components = name.split(whereSeparator: \.isWhitespace)

        guard let first = components.first?.first else { return "" }

        guard components.count > 1, let last = components.last?.first else {
            return String(first).uppercased()
        }

        return "\(first)\(last)".uppercased()
    }
}
