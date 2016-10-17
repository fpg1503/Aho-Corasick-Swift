public final class State: NSObject {

    public var depth: Int

    internal var rootState: State?

    internal var success: [Character: State] = [:]

    public var failure: State?
    public var emits: Set<String> = []

    convenience override init() {
        self.init(depth: 0)
    }

    init(depth: Int) {
        self.depth = depth
        self.rootState = nil
        super.init()

        self.rootState = depth == 0 ? self : nil
    }

    public func nextState(for character: Character, ignoreRootState: Bool) -> State? {
        var nextState = success[character]

        if !ignoreRootState && nextState == nil && rootState != nil {
            nextState = rootState
        }

        return nextState
    }

    public func addState(for character: Character) -> State {
        return nextState(for: character, ignoreRootState: true) ?? {
            let nextState = State(depth: depth + 1)
            success[character] = nextState

            return nextState
        }()
    }

    public func addEmit(_ keyword: String) {
        emits.insert(keyword)
    }


    public func addEmits(_ emits: [String]) {
        for emit in emits {
            addEmit(emit)
        }
    }

    var states: [State] {
        return Array(success.values)
    }

    var transitions: [Character] {
        return Array(success.keys)
    }

}
