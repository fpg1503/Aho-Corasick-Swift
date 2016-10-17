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

        let encodable = Trie.encode(value: trie)
        let data = NSKeyedArchiver.archivedData(withRootObject: encodable)

        let unarchived = NSKeyedUnarchiver.unarchiveObject(with: data)
        let decoded = Trie.decode(decodable: unarchived)

        print(decoded)
//        XCTAssertEqual(trie, decoded)
    }
}
