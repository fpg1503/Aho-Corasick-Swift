public struct MatchToken: Token {

    public var fragment: String
    public var emit: Emit?
    public var isMatch: Bool { return true }

}
