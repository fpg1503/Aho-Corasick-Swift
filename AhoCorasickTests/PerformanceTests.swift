import XCTest
@testable import AhoCorasick

class PerformanceTests: XCTestCase {

    private func loadFile(name: String, ofType type: String) -> String {
        guard let path = Bundle(for: PerformanceTests.self).path(forResource: name, ofType: type) else {
            XCTFail("\(name).\(type) does not exist")
            return ""
        }

        let url = URL(fileURLWithPath: path)

        guard let data = try? Data(contentsOf: url) else {
            XCTFail("\(name).\(type) does not have valid data")
            return ""
        }

        return String(data: data, encoding: .ascii) ?? ""
    }

    private func loadWords() -> [String] {
        let words = loadFile(name: "words", ofType: "txt").components(separatedBy: .newlines)
        XCTAssertEqual(words.count, 354986)

        return words
    }

    private func loadMobyDick() -> String {
        let mobyDick = loadFile(name: "moby_dick", ofType: "txt")
        XCTAssertFalse(mobyDick.isEmpty)

        return mobyDick
    }

    public func testWordsSimplePhrase() {
        let words = loadWords()

        let emits = "This is a simple test".find(substrings: words, options: [.caseInsensitive])

        var iterator = emits.makeIterator()

        XCTAssertEqual(iterator.next(), Emit(start: 0, end: 0, keyword: "t"))
        XCTAssertEqual(iterator.next(), Emit(start: 0, end: 1, keyword: "th"))
        XCTAssertEqual(iterator.next(), Emit(start: 1, end: 1, keyword: "h"))
        XCTAssertEqual(iterator.next(), Emit(start: 1, end: 2, keyword: "hi"))
        XCTAssertEqual(iterator.next(), Emit(start: 2, end: 2, keyword: "i"))
        XCTAssertEqual(iterator.next(), Emit(start: 3, end: 3, keyword: "s"))
        XCTAssertEqual(iterator.next(), Emit(start: 0, end: 3, keyword: "this"))
        XCTAssertEqual(iterator.next(), Emit(start: 1, end: 3, keyword: "his"))
        XCTAssertEqual(iterator.next(), Emit(start: 2, end: 3, keyword: "is"))
        XCTAssertEqual(iterator.next(), Emit(start: 5, end: 5, keyword: "i"))
        XCTAssertEqual(iterator.next(), Emit(start: 6, end: 6, keyword: "s"))
        XCTAssertEqual(iterator.next(), Emit(start: 5, end: 6, keyword: "is"))
        XCTAssertEqual(iterator.next(), Emit(start: 8, end: 8, keyword: "a"))
        XCTAssertEqual(iterator.next(), Emit(start: 10, end: 10, keyword: "s"))
        XCTAssertEqual(iterator.next(), Emit(start: 10, end: 11, keyword: "si"))
        XCTAssertEqual(iterator.next(), Emit(start: 11, end: 11, keyword: "i"))
        XCTAssertEqual(iterator.next(), Emit(start: 11, end: 12, keyword: "im"))
        XCTAssertEqual(iterator.next(), Emit(start: 12, end: 12, keyword: "m"))
        XCTAssertEqual(iterator.next(), Emit(start: 10, end: 12, keyword: "sim"))
        XCTAssertEqual(iterator.next(), Emit(start: 12, end: 13, keyword: "mp"))
        XCTAssertEqual(iterator.next(), Emit(start: 11, end: 13, keyword: "imp"))
        XCTAssertEqual(iterator.next(), Emit(start: 10, end: 13, keyword: "simp"))
        XCTAssertEqual(iterator.next(), Emit(start: 13, end: 13, keyword: "p"))
        XCTAssertEqual(iterator.next(), Emit(start: 13, end: 14, keyword: "pl"))
        XCTAssertEqual(iterator.next(), Emit(start: 14, end: 14, keyword: "l"))
        XCTAssertEqual(iterator.next(), Emit(start: 15, end: 15, keyword: "e"))
        XCTAssertEqual(iterator.next(), Emit(start: 10, end: 15, keyword: "simple"))
        XCTAssertEqual(iterator.next(), Emit(start: 14, end: 15, keyword: "le"))
        XCTAssertEqual(iterator.next(), Emit(start: 17, end: 17, keyword: "t"))
        XCTAssertEqual(iterator.next(), Emit(start: 18, end: 18, keyword: "e"))
        XCTAssertEqual(iterator.next(), Emit(start: 17, end: 18, keyword: "te"))
        XCTAssertEqual(iterator.next(), Emit(start: 18, end: 19, keyword: "es"))
        XCTAssertEqual(iterator.next(), Emit(start: 19, end: 19, keyword: "s"))
        XCTAssertEqual(iterator.next(), Emit(start: 18, end: 20, keyword: "est"))
        XCTAssertEqual(iterator.next(), Emit(start: 17, end: 20, keyword: "test"))
        XCTAssertEqual(iterator.next(), Emit(start: 19, end: 20, keyword: "st"))
        XCTAssertEqual(iterator.next(), Emit(start: 20, end: 20, keyword: "t"))
        XCTAssertNil(iterator.next())
    }

    public func testMobyDick() {
        let words = loadWords()
        let mobyDick = loadMobyDick()

        let emits = mobyDick.find(substrings: words)
        
        XCTAssertEqual(emits.count, 2208202)
    }

    public func testFindMobyAndDickInMobyDick() {
        let mobyDick = loadMobyDick()

        let emits = mobyDick.find(substrings: ["moby", "dick"], options: [.caseInsensitive])

        XCTAssertEqual(emits.count, 89*2)
    }

    public func testMobyDickRegex() {
        let words = loadWords()
        let mobyDick = loadMobyDick()
        let nsMoby = mobyDick as NSString

        let pattern = "(" + words.joined(separator: "|") + ")"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        XCTAssertNotNil(regex)

        let wholeRange = NSRange(location: 0, length: mobyDick.characters.count)
        let range = mobyDick.startIndex..<mobyDick.endIndex
        XCTAssertEqual(nsMoby, mobyDick.substring(with: range) as NSString)
        print("Regex creation is Ok!")

        let emits = mobyDick.find(substrings: words)
        XCTAssertEqual(emits.count, 2208202)
        print("Aho-Corasick is Ok!")

        //Takes about 4316630 seconds
        let matches = regex?.matches(in: mobyDick, options: [], range: wholeRange) ?? []
        XCTAssertEqual(matches.count, 1232639)
        print("Regex is Ok!")

        for match in matches {
            let start = match.range.location
            let end = match.range.length - start - 1

            let keyword = nsMoby.substring(with: match.range)

            let emit = Emit(start: start, end: end, keyword: keyword)

            XCTAssertTrue(emits.contains(emit))
        }
    }
}
