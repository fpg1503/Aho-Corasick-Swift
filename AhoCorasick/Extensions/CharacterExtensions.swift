import Foundation

extension Character {
    func lowercased() -> Character {
        let string = String(self)
        let lowercasedString = string.lowercased()
        return lowercasedString.characters.first ?? self
    }
}
