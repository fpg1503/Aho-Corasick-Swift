extension State: Persistable, NSCoding {

    public convenience init?(coder aDecoder: NSCoder) {
        guard let _success = aDecoder.decodeObject(forKey: "success") as? [Character: State] else {
            return nil
        }
        self.init()

        depth       = aDecoder.decodeInteger(forKey: "depth")
        rootState   = aDecoder.decodeObject(forKey: "rootState") as? State
        success     = _success
        failure     = aDecoder.decodeObject(forKey: "failure") as? State
        emits       = Set(aDecoder.decodeObject(forKey: "emits") as? [String] ?? [])
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(depth, forKey: "depth")
        aCoder.encode(rootState, forKey: "rootState")
        aCoder.encode(success, forKey: "success")
        aCoder.encode(failure, forKey: "failure")
        aCoder.encode(Array(emits), forKey: "emits")
    }

    static func encode(value: State) -> Encodable {
        return value
    }

    static func decode(decodable: Decodable) -> State? {
        return decodable as? State
    }
}
