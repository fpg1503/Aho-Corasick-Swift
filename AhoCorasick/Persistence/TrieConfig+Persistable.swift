extension TrieConfig: Persistable {
    class NSCodable: NSCoding {

        let value: TrieConfig

        init(value: TrieConfig) {
            self.value = value
        }

        required init?(coder aDecoder: NSCoder) {
            let removeOverlaps = aDecoder.decodeBool(forKey: "removeOverlaps")
            let onlyDelimited = aDecoder.decodeBool(forKey: "onlyDelimited")
            let caseInsensitive = aDecoder.decodeBool(forKey: "caseInsensitive")
            let diacriticInsensitive = aDecoder.decodeBool(forKey: "diacriticInsensitive")
            let stopOnHit = aDecoder.decodeBool(forKey: "stopOnHit")

            value = TrieConfig(removeOverlaps: removeOverlaps, onlyDelimited: onlyDelimited, caseInsensitive: caseInsensitive, diacriticInsensitive: diacriticInsensitive, stopOnHit: stopOnHit)
        }

        func encode(with aCoder: NSCoder) {
            aCoder.encode(value.removeOverlaps, forKey: "removeOverlaps")
            aCoder.encode(value.onlyDelimited, forKey: "onlyDelimited")
            aCoder.encode(value.caseInsensitive, forKey: "caseInsensitive")
            aCoder.encode(value.diacriticInsensitive, forKey: "diacriticInsensitive")
            aCoder.encode(value.stopOnHit, forKey: "stopOnHit")
        }
    }

    static func encode(value: TrieConfig) -> Encodable {
        return NSCodable(value: value)
    }

    static func decode(decodable: Decodable) -> TrieConfig? {
        return NSCodable(coder: decodable)?.value
    }
}
