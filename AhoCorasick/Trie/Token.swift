public protocol Token {

	var fragment: String { get set }
    var isMatch: Bool { get }
    var emit: Emit? { get }

}
