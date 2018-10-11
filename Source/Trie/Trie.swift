import Foundation

public struct Trie {
    private var config: TrieConfig
    private let rootState: State = State()

    private func add(keyword: String) {
        guard !keyword.isEmpty else { return }

        var currentState = rootState

        for var character in keyword {
            if config.caseInsensitive {
                character = character.lowercased()
            }
            if config.diacriticInsensitive {
                character = character.removingDiacritics()
            }
            currentState = currentState.addState(for: character)
        }

        var keyword = keyword
        if config.caseInsensitive {
            keyword = keyword.lowercased()
        }
        if config.diacriticInsensitive {
            keyword = keyword.removingDiacritics()
        }

        currentState.addEmit(keyword)
    }

    public func tokenize(text: String) -> [Token] {

        var tokens = [Token]()
        let collectedEmits = parse(text: text)

        var lastCollectedPosition = -1
        //TODO: Swiftify

        for emit in collectedEmits {
            if emit.start - lastCollectedPosition > 1 {
                tokens.append(createFragment(emit, text: text, lastCollectedPosition: lastCollectedPosition))
            }
            tokens.append(createMatch(emit, text: text))
            lastCollectedPosition = emit.end
        }
        if text.count - lastCollectedPosition > 1 {
            tokens.append(createFragment(nil, text: text, lastCollectedPosition: lastCollectedPosition))
        }

        return tokens
    }

    private func createFragment(_ emit: Emit?, text: String, lastCollectedPosition: Int) -> Token {
        let begin = text.index(text.startIndex, offsetBy: lastCollectedPosition + 1)
        let end = text.index(text.startIndex, offsetBy: emit?.start ?? text.count)
        let substring = text[begin..<end]
        return FragmentToken(fragment: String(substring))
    }

    private func createMatch(_ emit: Emit, text: String) -> Token {
        let begin = text.index(text.startIndex, offsetBy: emit.start)
        let end = text.index(text.startIndex, offsetBy: emit.end + 1)
        let substring = text[begin..<end]
        return MatchToken(fragment: String(substring), emit: emit)
    }

    public func parse(text: String) -> [Emit] {

        var collectedEmits = collectEmits(for: text)

        if config.onlyDelimited {
            collectedEmits = removePartialMatches(searchText: text, collectedEmits: collectedEmits)
        }

        if config.removeOverlaps {
            let intervalTree = IntervalTree(intervals: collectedEmits)
            collectedEmits = intervalTree.removeOverlaps(intervals: collectedEmits)
        }

        return collectedEmits;
    }

    public func containsMatch(text: String) -> Bool {
        let firstMatch = self.firstMatch(text: text)
        return firstMatch != nil
    }

    private func collectEmits(for text: String) -> [Emit] {
        var currentState = rootState
        var storedEmits = [Emit]()
        for (position, character) in text.enumerated() {
            var character = character

            if config.caseInsensitive {
                character = character.lowercased()
            }
            if config.diacriticInsensitive {
                character = character.removingDiacritics()
            }

            currentState = getState(currentState: currentState, character: character)
            let newEmits = storeEmits(position: position, currentState: currentState)
            if newEmits.count > 0 && config.stopOnHit {
                return newEmits
            }
            storedEmits += newEmits
        }
        return storedEmits
    }

    public func firstMatch(text: String) -> Emit? {
        if config.removeOverlaps {
            let parseText = self.parse(text: text)
            if !parseText.isEmpty {
                return parseText.first
            }
        } else {
            var currentState = rootState

            for (position, character) in text.enumerated() {
                var character = character

                if config.caseInsensitive {
                    character = character.lowercased()
                }
                if config.diacriticInsensitive {
                    character = character.removingDiacritics()
                }
                
                currentState = getState(currentState: currentState, character: character)
                let emitStrings = currentState.emits

                for string in emitStrings {
                    let emit = Emit(start: position - string.count + 1, end: position, keyword: string)
                    if config.onlyDelimited {
                        if !isPartialMatch(searchText: text, emit: emit) {
                            return emit
                        }
                    } else {
                        return emit
                    }
                }
            }
        }
        return nil
    }

    private func isPartialMatch(searchText: String, emit: Emit) -> Bool {
        let characterBeforeIsNotBoundary: Bool = {
            guard emit.start > 0 else { return false }

            let offset = emit.start - 1
            let index = searchText.index(searchText.startIndex, offsetBy: offset)
            let characterBefore = searchText[index]

            return !characterBefore.isWordBoundary
        }()
        let characterAfterIsNotBoundary: Bool = {
            guard emit.end + 1 < searchText.count else { return false }

            let offset = emit.end + 1
            let index = searchText.index(searchText.startIndex, offsetBy: offset)
            let characterAfter = searchText[index]

            return !characterAfter.isWordBoundary
        }()

        return characterBeforeIsNotBoundary || characterAfterIsNotBoundary
    }

    private func removePartialMatches(searchText: String, collectedEmits: [Emit]) -> [Emit] {

        let nonPartialMatches = collectedEmits.filter { !isPartialMatch(searchText: searchText, emit: $0) }

        return nonPartialMatches
    }

    private func getState(currentState: State, character: Character) -> State {
        var currentState = currentState
        var newCurrentState = currentState.nextState(for: character, ignoreRootState: false)

        while newCurrentState == nil {
            currentState = currentState.failure!
            newCurrentState = currentState.nextState(for: character, ignoreRootState: false)
        }
        return newCurrentState!
    }

    private func constructFailureStates() {
        var queue = [State]()

        for depthOneState in rootState.states {
            depthOneState.failure = rootState
            queue.append(depthOneState)
        }

        while !queue.isEmpty {
            let currentState = queue.removeFirst()

            for transition in currentState.transitions {
                let targetState = currentState.nextState(for: transition, ignoreRootState: false)

                queue.append(targetState!)

                var traceFailureState = currentState.failure
                while traceFailureState?.nextState(for: transition, ignoreRootState: false) == nil {
                    traceFailureState = traceFailureState?.failure
                }

                let newFailureState = traceFailureState?.nextState(for: transition, ignoreRootState: false)
                targetState?.failure = newFailureState
                targetState?.addEmit(Array(newFailureState?.emits ?? []))
                
            }
        }
    }

    private func storeEmits(position: Int, currentState: State) -> [Emit] {
        let emits = currentState.emits

        var storedEmits = [Emit]()

        for emit in emits {
            storedEmits.append(Emit(start: position - emit.count + 1, end: position, keyword: emit))
        }

        return storedEmits
    }

    init() {
        config = TrieConfig()
    }

    public init(config: TrieConfig, keywords: [String]) {
        self.config = config

        for keyword in keywords {
            add(keyword: keyword)
        }

        constructFailureStates()
    }

    public static func builder() -> TrieBuilder {
        return TrieBuilder()
    }

    public class TrieBuilder {

        private var trie: Trie = Trie()

        public func caseInsensitive() -> TrieBuilder {
            trie.config.caseInsensitive = true
            return self
        }

        public func diacriticInsensitive() -> TrieBuilder {
            trie.config.diacriticInsensitive = true
            return self
        }

        public func removeOverlaps() -> TrieBuilder {
            trie.config.removeOverlaps = true
            return self
        }

        public func onlyDelimited() -> TrieBuilder {
            trie.config.onlyDelimited = true
            return self
        }

        public func add(keyword: String) -> TrieBuilder {
            trie.add(keyword: keyword)
            return self
        }

        public func stopOnHit() -> TrieBuilder {
            trie.config.stopOnHit = true
            return self
        }

        public func build() -> Trie {
            trie.constructFailureStates()
            return trie
        }

    }
}
