public struct FragmentToken: Token {

    public var fragment: String
    public var emit: Emit? { return nil }
    public var isMatch: Bool { return false }

}
