typealias Encodable = NSCoding
typealias Decodable = Any?

protocol Persistable {
    static func encode(value: Self) -> Encodable
    static func decode(decodable: Decodable) -> Self?
}
