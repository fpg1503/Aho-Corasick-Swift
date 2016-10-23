public struct Emit: Interval {
    public var start: Int
    public var end: Int
    public var keyword: String
}

extension Emit: CustomStringConvertible {
    public var description: String {
        return "\(start):\(end)=\(keyword)"
    }
}

extension Emit: Equatable { }
