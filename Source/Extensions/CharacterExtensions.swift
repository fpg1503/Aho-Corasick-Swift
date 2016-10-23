import Foundation

extension Character {
    func lowercased() -> Character {
        let string = String(self)
        let lowercasedString = string.lowercased()
        return lowercasedString.characters.first ?? self
    }

    func removingDiacritics() -> Character {
        let string = String(self)
        let stringRemovingDiacritics = string.removingDiacritics()
        return stringRemovingDiacritics.characters.first ?? self
    }

    var isWordBoundary: Bool {
        guard self != "a" else { return false }

        let nonCharacter = "a"

        let string = nonCharacter + String(self)
        let wholeRange = NSRange(location: 0, length: string.characters.count)

        let pattern = nonCharacter + "\\b"
        let regex = try? NSRegularExpression(pattern: pattern, options: .useUnicodeWordBoundaries)

        let count = regex?.numberOfMatches(in: string, range: wholeRange) ?? 0

        return count != 0
    }
}
