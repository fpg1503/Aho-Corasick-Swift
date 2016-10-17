extension Trie: Persistable {
    class NSCodable: NSCoding {

        let value: Trie

        init(value: Trie) {
            self.value = value
        }

        required init?(coder aDecoder: NSCoder) {
            guard let config = aDecoder.decodeObject(forKey: "trieConfig") as? TrieConfig.NSCodable,
                let rootState = aDecoder.decodeObject(forKey: "rootState") as? State else {
                return nil
            }


            value = Trie(config: config.value, rootState: rootState)
        }

        func encode(with aCoder: NSCoder) {
            let config = TrieConfig.NSCodable(value: value.config)

            aCoder.encode(config, forKey: "trieConfig")
            aCoder.encode(value.rootState, forKey: "rootState")
        }
    }

    static func encode(value: Trie) -> Encodable {
        return NSCodable(value: value)
    }

    static func decode(decodable: Decodable) -> Trie? {
        return NSCodable(coder: decodable)?.value
    }
}
