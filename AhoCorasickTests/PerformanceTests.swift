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

    public func testMobyDick() {
        let words = loadFile(name: "words", ofType: "txt").components(separatedBy: .newlines)
        XCTAssertEqual(words.count, 354986)

        let mobyDick = loadFile(name: "moby_dick", ofType: "txt")
        XCTAssertFalse(mobyDick.isEmpty)

        let emits = mobyDick.find(substrings: words)
        
        XCTAssertEqual(emits.count, 2208202)
    }

    public func testMobyDickRegex() {
        let words = loadFile(name: "words", ofType: "txt").components(separatedBy: .newlines)
        XCTAssertEqual(words.count, 354986)

        let mobyDick = loadFile(name: "moby_dick", ofType: "txt")
        XCTAssertFalse(mobyDick.isEmpty)

        let pattern = "(" + words.joined(separator: "|") + ")"

        let regex = try? NSRegularExpression(pattern: pattern, options: [])

        let wholeRange = NSRange(location: 0, length: mobyDick.characters.count)
        //Takes about 4316630 seconds
        let matches = regex?.matches(in: mobyDick, options: [], range: wholeRange) ?? []

        let emits = mobyDick.find(substrings: words)

        let nsMoby = mobyDick as NSString

        for match in matches {
            let start = match.range.location
            let end = match.range.length - start - 1

            let keyword = nsMoby.substring(with: match.range)

            let emit = Emit(start: start, end: end, keyword: keyword)

            XCTAssertTrue(emits.contains(emit))
        }


        XCTAssertEqual(matches.count, 1232639)
    }
}
