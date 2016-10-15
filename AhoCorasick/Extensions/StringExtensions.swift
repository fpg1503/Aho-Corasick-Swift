import Foundation

public struct TrieOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let caseInsensitive  = TrieOptions(rawValue: 1 << 0)
    static let removeOverlaps   = TrieOptions(rawValue: 1 << 1)
    static let onlyDelimited    = TrieOptions(rawValue: 1 << 2)
    static let stopOnHit        = TrieOptions(rawValue: 1 << 3)

    var trieConfig: TrieConfig {
        let removeOverlaps = contains(.removeOverlaps)
        let onlyDelimited = contains(.onlyDelimited)
        let caseInsensitive = contains(.caseInsensitive)
        let stopOnHit = contains(.stopOnHit)

        return TrieConfig(removeOverlaps: removeOverlaps, onlyDelimited: onlyDelimited, caseInsensitive: caseInsensitive, stopOnHit: stopOnHit)
    }

}

public extension String {
    public func parse(with trie: Trie) -> [Emit] {
        return trie.parse(text: self)
    }

    public func find(substrings: [String], options: TrieOptions = []) -> [Emit] {
        let config = options.trieConfig

        let trie = Trie(config: config, keywords: substrings)
        
        return trie.parse(text: self)
    }
}
