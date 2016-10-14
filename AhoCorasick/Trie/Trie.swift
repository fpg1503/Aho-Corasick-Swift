import Foundation

public struct Trie {
    private var config: TrieConfig
    private let rootState: State = State()

    private func add(keyword: String) {
        guard !keyword.isEmpty else { return }

        var currentState = rootState

        for var character in keyword.characters {
            if config.caseInsensitive {
                character = character.lowercased()
            }
            currentState = currentState.addState(for: character)
        }
        currentState.addEmit(config.caseInsensitive ? keyword.lowercased() : keyword)
    }

    public func tokenize(text: String) -> [Token] {

        var tokens = [Token]()
        let collectedEmits = parse(text: text)

        var lastCollectedPosition = -1 //TODO: Swiftify

        for emit in collectedEmits {
            if emit.start - lastCollectedPosition > 1 {
                tokens.append(createFragment(emit, text: text, lastCollectedPosition: lastCollectedPosition))
            }
            tokens.append(createMatch(emit, text: text))
            lastCollectedPosition = emit.end
        }
        if text.characters.count - lastCollectedPosition > 1 {
            tokens.append(createFragment(nil, text: text, lastCollectedPosition: lastCollectedPosition))
        }

        return tokens
    }

    private func createFragment(_ emit: Emit?, text: String, lastCollectedPosition: Int) -> Token {
        let begin = text.index(text.startIndex, offsetBy: lastCollectedPosition + 1)
        let end = text.index(text.startIndex, offsetBy: emit?.start ?? text.characters.count)
        let substring = text[begin..<end]
        return FragmentToken(fragment: substring)
    }

    private func createMatch(_ emit: Emit, text: String) -> Token {
        let begin = text.index(text.startIndex, offsetBy: emit.start)
        let end = text.index(text.startIndex, offsetBy: emit.end + 1)
        let substring = text[begin..<end]
        return MatchToken(fragment: substring, emit: emit)
    }

    public func parse(text: String) -> [Emit] {

        var collectedEmits = collectEmits(for: text)

        if config.onlyDelimited {
            collectedEmits = removePartialMatches(searchText: text, collectedEmits: collectedEmits)
        }

        if !config.allowsOverlaps {
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
        for (position, character) in text.characters.enumerated() {
            var character = character

            if config.caseInsensitive {
                character = character.lowercased()
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
        if !config.allowsOverlaps {
            let parseText = self.parse(text: text)
            if !parseText.isEmpty {
                return parseText.first
            }
        } else {
            var currentState = rootState

            for (position, character) in text.characters.enumerated() {
                var character = character

                if config.caseInsensitive {
                    character = character.lowercased()
                }
                currentState = getState(currentState: currentState, character: character)
                let emitStrings = currentState.emits

                for string in emitStrings {
                    let emit = Emit(start: position - string.characters.count + 1, end: position, keyword: string)
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
        func isNotBoundary(_ character: Character) -> Bool {
            guard character != "a" else { return true }

            let nonCharacter = "a"

            let string = nonCharacter + String(character)
            let wholeRange = NSRange(location: 0, length: string.characters.count)

            let pattern = nonCharacter + "\\b"
            let regex = try? NSRegularExpression(pattern: pattern, options: .useUnicodeWordBoundaries)

            let count = regex?.numberOfMatches(in: string, range: wholeRange) ?? 0
            
            return count == 0
        }

        let characterBeforeIsNotBoundary: Bool = {
            guard emit.start > 0 else { return false }

            let offset = emit.start - 1
            let index = searchText.index(searchText.startIndex, offsetBy: offset)
            let characterBefore = searchText.characters[index]

            return isNotBoundary(characterBefore)
        }()
        let characterAfterIsNotBoundary: Bool = {
            guard emit.end + 1 < searchText.characters.count else { return false }

            let offset = emit.end + 1
            let index = searchText.index(searchText.startIndex, offsetBy: offset)
            let characterAfter = searchText.characters[index]

            return isNotBoundary(characterAfter)
        }()

        return characterBeforeIsNotBoundary || characterAfterIsNotBoundary
    }

    private func removePartialMatches(searchText: String, collectedEmits: [Emit]) -> [Emit] {
        var collectedEmits = collectedEmits
    //TODO: Swiftify
        var removeEmits = [Emit]()

        for emit in collectedEmits {
            if isPartialMatch(searchText: searchText, emit: emit) {
                removeEmits.append(emit)
            }
        }

        for emit in removeEmits {
            collectedEmits.remove(at: collectedEmits.index(of: emit)!)
        }

        return collectedEmits
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
            storedEmits.append(Emit(start: position - emit.characters.count + 1, end: position, keyword: emit))
        }

        return storedEmits
    }

    public static func builder() -> TrieBuilder {
        return TrieBuilder()
    }

    public class TrieBuilder {

        private var trie: Trie = Trie(config: TrieConfig())

        public func caseInsensitive() -> TrieBuilder {
            trie.config.caseInsensitive = true
            return self
        }

        public func removeOverlaps() -> TrieBuilder {
            trie.config.allowsOverlaps = false
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
