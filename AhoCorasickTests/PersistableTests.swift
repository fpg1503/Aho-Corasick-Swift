import XCTest
@testable import AhoCorasick

class PersistableTests: XCTestCase {
    func testPeristTrie() {
        let trie = Trie.builder()
            .caseInsensitive()
            .diacriticInsensitive()
            .add(keyword: "banana")
            .add(keyword: "bat")
            .add(keyword: "battery")
            .add(keyword: "apple pie")
            .build()

        let text = "Test, banana, bat, battery, pineapple pie, apple pie"

        let emitsBefore = text.parse(with: trie)

        let encodable = Trie.encode(value: trie)
        let data = NSKeyedArchiver.archivedData(withRootObject: encodable)

        let unarchived = NSKeyedUnarchiver.unarchiveObject(with: data)
        let decodedTrie = Trie.decode(decodable: unarchived)
        XCTAssertNotNil(decodedTrie)

        let emitsAfter = decodedTrie.map { text.parse(with: $0) } ?? []

        XCTAssertEqual(emitsBefore, emitsAfter)
    }
}
