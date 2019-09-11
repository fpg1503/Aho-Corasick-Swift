import Foundation

public struct TrieOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let removeOverlaps       = TrieOptions(rawValue: 1 << 0)
    static let onlyDelimited        = TrieOptions(rawValue: 1 << 1)
    static let caseInsensitive      = TrieOptions(rawValue: 1 << 2)
    static let diacriticInsensitive = TrieOptions(rawValue: 1 << 3)
    static let stopOnHit            = TrieOptions(rawValue: 1 << 4)

    var trieConfig: TrieConfig {
        let removeOverlaps          = contains(.removeOverlaps)
        let onlyDelimited           = contains(.onlyDelimited)
        let caseInsensitive         = contains(.caseInsensitive)
        let diacriticInsensitive    = contains(.diacriticInsensitive)
        let stopOnHit               = contains(.stopOnHit)

        return TrieConfig(removeOverlaps: removeOverlaps, onlyDelimited: onlyDelimited, caseInsensitive: caseInsensitive, diacriticInsensitive: diacriticInsensitive, stopOnHit: stopOnHit)
    }

}

public extension String {
    func removingDiacritics() -> String {
        return folding(options: .diacriticInsensitive, locale: nil)
    }

    func parse(with trie: Trie) -> [Emit] {
        return trie.parse(text: self)
    }

    func find(substrings: [String], options: TrieOptions = []) -> [Emit] {
        let config = options.trieConfig

        let trie = Trie(config: config, keywords: substrings)
        
        return trie.parse(text: self)
    }
}
