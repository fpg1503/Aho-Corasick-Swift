typealias Encodable = NSCoding
typealias Decodable = NSCoder

protocol Persistable {
    static func encode(value: Self) -> Encodable
    static func decode(decodable: Decodable) -> Self?
}
