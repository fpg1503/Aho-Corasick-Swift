import XCTest
@testable import AhoCorasick

class AhoCorasickTests: XCTestCase {

    public func testKeywordAndTextAreTheSame() {
        let trie = Trie.builder()
            .add(keyword: "abc")
            .build()

        let emits = trie.parse(text: "abc")

        let expectedEmit = Emit(start: 0, end: 2, keyword: "abc")

        XCTAssertEqual(emits.first, expectedEmit)
    }

    public func testKeywordAndTextAreTheSameFirstMatch() {
        let trie = Trie.builder()
            .add(keyword: "abc")
            .build()

        let firstMatch = trie.firstMatch(text: "abc")

        let expectedEmit = Emit(start: 0, end: 2, keyword: "abc")

        XCTAssertEqual(firstMatch, expectedEmit)
    }


    public func testTextIsLongerThanKeyword() {
        let trie = Trie.builder()
            .add(keyword: "abc")
            .build()


        let emits = trie.parse(text: " abc")
        let expectedEmit = Emit(start: 1, end: 3, keyword: "abc")
        XCTAssertEqual(emits.first, expectedEmit)
    }

    public func testTextIsLongerThanKeywordFirstMatch() {
        let trie = Trie.builder()
            .add(keyword: "abc")
            .build()
        let firstMatch = trie.firstMatch(text: " abc")
        let expectedEmit = Emit(start: 1, end: 3, keyword: "abc")
        XCTAssertEqual(firstMatch, expectedEmit)
    }

    public func testVariousKeywordsOneMatch() {
        let trie = Trie.builder()
            .add(keyword: "abc")
            .add(keyword: "bcd")
            .add(keyword: "cde")
            .build()
        let emits = trie.parse(text: "bcd")
        let expectedEmit = Emit(start: 0, end: 2, keyword: "bcd")
        XCTAssertEqual(emits.first, expectedEmit)
    }

    public func testVariousKeywordsFirstMatch() {
        let trie = Trie.builder()
            .add(keyword: "abc")
            .add(keyword: "bcd")
            .add(keyword: "cde")
            .build()
        let firstMatch = trie.firstMatch(text: "bcd")
        let expectedEmit = Emit(start: 0, end: 2, keyword: "bcd")
        XCTAssertEqual(firstMatch, expectedEmit)
    }

    public func testUshersAndStopOnHit() {
        let trie = Trie.builder()
            .add(keyword: "hers")
            .add(keyword: "his")
            .add(keyword: "she")
            .add(keyword: "he")
            .stopOnHit()
            .build()
        let emits = trie.parse(text: "ushers")
        XCTAssertEqual(emits.count, 2) // she @ 3, he @ 3

        let expectedEmits = [Emit(start: 2, end: 3, keyword: "he"),
                             Emit(start: 1, end: 3, keyword: "she")]

        assertContainsAll(expected: expectedEmits, actual: emits)
    }

    public func testUshers() {
        let trie = Trie.builder()
            .add(keyword: "hers")
            .add(keyword: "his")
            .add(keyword: "she")
            .add(keyword: "he")
            .build()
        let emits = trie.parse(text: "ushers")
        XCTAssertEqual(emits.count, 3)// she @ 3, he @ 3, hers @ 5

        let expectedEmits = [Emit(start: 2, end: 3, keyword: "he"),
                             Emit(start: 1, end: 3, keyword: "she"),
                             Emit(start: 2, end: 5, keyword: "hers")]

        assertContainsAll(expected: expectedEmits, actual: emits)
    }

    public func testUshersUppercaseKeywords() {
        let trie = Trie.builder()
            .caseInsensitive()
            .add(keyword: "HERS")
            .add(keyword: "HIS")
            .add(keyword: "SHE")
            .add(keyword: "HE")
            .build()
        let emits = trie.parse(text: "ushers")


        XCTAssertEqual(emits.count, 3)// she @ 3, he @ 3, hers @ 5

        let expectedEmits = [Emit(start: 2, end: 3, keyword: "he"),
                             Emit(start: 1, end: 3, keyword: "she"),
                             Emit(start: 2, end: 5, keyword: "hers")]

        assertContainsAll(expected: expectedEmits, actual: emits)
    }

    //    The order is not deterministic, that's probably a bug
    //    public func testUshersFirstMatch() {
    //        let trie = Trie.builder()
    //            .add(keyword: "hers")
    //            .add(keyword: "his")
    //            .add(keyword: "she")
    //            .add(keyword: "he")
    //            .build()
    //        let firstMatch = trie.firstMatch(text: "ushers")
    //        let expectedEmit = Emit(start: 1, end: 3, keyword: "she")
    //
    //        XCTAssertEqual(firstMatch, expectedEmit)
    //    }

    public func testMisleading() {
        let trie = Trie.builder()
            .add(keyword: "hers")
            .build()
        let emits = trie.parse(text: "h he her hers")
        let expectedEmit = Emit(start: 9, end: 12, keyword: "hers")
        XCTAssertEqual(emits.first, expectedEmit)
    }

    public func testMisleadingFirstMatch() {
        let trie = Trie.builder()
            .add(keyword: "hers")
            .build()
        let firstMatch = trie.firstMatch(text: "h he her hers")
        let expectedEmit = Emit(start: 9, end: 12, keyword: "hers")
        XCTAssertEqual(firstMatch, expectedEmit)
    }

    public func testRecipes() {
        let trie = Trie.builder()
            .add(keyword: "veal")
            .add(keyword: "cauliflower")
            .add(keyword: "broccoli")
            .add(keyword: "tomatoes")
            .build()
        let emits = trie.parse(text: "2 cauliflowers, 3 tomatoes, 4 slices of veal, 100g broccoli")
        let expectedEmit0 = Emit(start: 2, end: 12, keyword: "cauliflower")
        XCTAssertEqual(emits[0], expectedEmit0)
        let expectedEmit1 = Emit(start: 18, end: 25, keyword: "tomatoes")
        XCTAssertEqual(emits[1], expectedEmit1)
        let expectedEmit2 = Emit(start: 40, end: 43, keyword: "veal")
        XCTAssertEqual(emits[2], expectedEmit2)
        let expectedEmit3 = Emit(start: 51, end: 58, keyword: "broccoli")
        XCTAssertEqual(emits[3], expectedEmit3)
    }

    public func testRecipesFirstMatch() {
        let trie = Trie.builder()
            .add(keyword: "veal")
            .add(keyword: "cauliflower")
            .add(keyword: "broccoli")
            .add(keyword: "tomatoes")
            .build()
        let firstMatch = trie.firstMatch(text: "2 cauliflowers, 3 tomatoes, 4 slices of veal, 100g broccoli")

        let expectedEmit = Emit(start: 2, end: 12, keyword: "cauliflower")
        XCTAssertEqual(firstMatch, expectedEmit)
    }

    public func testLongAndShortOverlappingMatch() {
        let trie = Trie.builder()
            .add(keyword: "he")
            .add(keyword: "hehehehe")
            .build()
        let emits = trie.parse(text: "hehehehehe")

        let expectedEmits = [Emit(start: 0, end: 1, keyword: "he"),
                             Emit(start: 2, end: 3, keyword: "he"),
                             Emit(start: 4, end: 5, keyword: "he"),
                             Emit(start: 0, end: 7, keyword: "hehehehe"),
                             Emit(start: 6, end: 7, keyword: "he"),
                             Emit(start: 2, end: 9, keyword: "hehehehe"),
                             Emit(start: 8, end: 9, keyword: "he")]

        assertContainsAll(expected: expectedEmits, actual: emits)
    }

    public func testNonOverlapping() {
        let trie = Trie.builder().removeOverlaps()
            .add(keyword: "ab")
            .add(keyword: "cba")
            .add(keyword: "ababc")
            .build()
        let emits = trie.parse(text: "ababcbab")

        XCTAssertEqual(emits.count, 2)
        // With overlaps: ab@1, ab@3, ababc@4, cba@6, ab@7
        let expectedEmit0 = Emit(start: 0, end: 4, keyword: "ababc")
        XCTAssertEqual(emits[0], expectedEmit0)
        let expectedEmit1 = Emit(start: 6, end: 7, keyword: "ab")
        XCTAssertEqual(emits[1], expectedEmit1)
    }

    public func testNonOverlappingFirstMatch() {
        let trie = Trie.builder().removeOverlaps()
            .add(keyword: "ab")
            .add(keyword: "cba")
            .add(keyword: "ababc")
            .build()
        let firstMatch = trie.firstMatch(text: "ababcbab")

        let expectedEmit = Emit(start: 0, end: 4, keyword: "ababc")
        XCTAssertEqual(firstMatch, expectedEmit)
    }

    public func testContainsMatch() {
        let trie = Trie.builder().removeOverlaps()
            .add(keyword: "ab")
            .add(keyword: "cba")
            .add(keyword: "ababc")
            .build()

        XCTAssert(trie.containsMatch(text: "ababcbab"))
    }

    public func testStartOfChurchillSpeech() {
        let trie = Trie.builder().removeOverlaps()
            .add(keyword: "T")
            .add(keyword: "u")
            .add(keyword: "ur")
            .add(keyword: "r")
            .add(keyword: "urn")
            .add(keyword: "ni")
            .add(keyword: "i")
            .add(keyword: "in")
            .add(keyword: "n")
            .add(keyword: "urning")
            .build()
        let emits = trie.parse(text: "Turning")

        XCTAssertEqual(emits.count, 2)
    }

    public func testPartialMatch() {
        let trie = Trie.builder()
            .onlyDelimited()
            .add(keyword: "sugar")
            .build()
        let emits = trie.parse(text: "sugarcane sugarcane sugar canesugar") // left, middle, right test

        XCTAssertEqual(emits.count, 1)

        let expectedEmit = Emit(start: 20, end: 24, keyword: "sugar")

        XCTAssertEqual(emits.first, expectedEmit)
    }

    public func testPartialMatchFirstMatch() {
        let trie = Trie.builder()
            .onlyDelimited()
            .add(keyword: "sugar")
            .build()
        let firstMatch = trie.firstMatch(text: "sugarcane sugarcane sugar canesugar") // left, middle, right test

        let expectedEmit = Emit(start: 20, end: 24, keyword: "sugar")
        XCTAssertEqual(firstMatch, expectedEmit)
    }

    public func testTokenizeFullSentence() {
        let trie = Trie.builder()
            .add(keyword: "Alpha")
            .add(keyword: "Beta")
            .add(keyword: "Gamma")
            .build()

        let tokens = trie.tokenize(text: "Hear: Alpha team first, Beta from the rear, Gamma in reserve")

        XCTAssertEqual(tokens.count, 7)

        var iterator = tokens.makeIterator()


        XCTAssertEqual(iterator.next()?.fragment, "Hear: ")
        XCTAssertEqual(iterator.next()?.fragment, "Alpha")
        XCTAssertEqual(iterator.next()?.fragment, " team first, ")
        XCTAssertEqual(iterator.next()?.fragment, "Beta")
        XCTAssertEqual(iterator.next()?.fragment, " from the rear, ")
        XCTAssertEqual(iterator.next()?.fragment, "Gamma")
        XCTAssertEqual(iterator.next()?.fragment, " in reserve")
    }

    public func testRobertBorBug5InGithubReportedByXCurry() {
        let trie = Trie.builder().caseInsensitive().onlyDelimited()
            .add(keyword: "turning")
            .add(keyword: "once")
            .add(keyword: "again")
            .add(keyword: "börkü")
            .build()
        let emits = trie.parse(text: "TurninG OnCe AgAiN BÖRKÜ")

        XCTAssertEqual(emits.count, 4)

        var iterator = emits.makeIterator()

        XCTAssertEqual(iterator.next(), Emit(start: 0, end: 6, keyword: "turning"))
        XCTAssertEqual(iterator.next(), Emit(start: 8, end: 11, keyword: "once"))
        XCTAssertEqual(iterator.next(), Emit(start: 13, end: 17, keyword: "again"))
        XCTAssertEqual(iterator.next(), Emit(start: 19, end: 23, keyword: "börkü"))
    }


    public func testCaseInsensitive() {
        let trie = Trie.builder().caseInsensitive()
            .add(keyword: "turning")
            .add(keyword: "once")
            .add(keyword: "again")
            .add(keyword: "börkü")
            .build()
        let emits = trie.parse(text: "TurninG OnCe AgAiN BÖRKÜ")
        XCTAssertEqual(emits.count, 4)
        var iterator = emits.makeIterator()
        XCTAssertEqual(iterator.next(), Emit(start: 0, end: 6, keyword: "turning"))
        XCTAssertEqual(iterator.next(), Emit(start: 8, end: 11, keyword: "once"))
        XCTAssertEqual(iterator.next(), Emit(start: 13, end: 17, keyword: "again"))
        XCTAssertEqual(iterator.next(), Emit(start: 19, end: 23, keyword: "börkü"))
    }

    public func testCaseInsensitiveFirstMatch() {
        let trie = Trie.builder().caseInsensitive()
            .add(keyword: "turning")
            .add(keyword: "once")
            .add(keyword: "again")
            .add(keyword: "börkü")
            .build()
        let firstMatch = trie.firstMatch(text: "TurninG OnCe AgAiN BÖRKÜ")

        let expectedEmit = Emit(start: 0, end: 6, keyword: "turning")
        XCTAssertEqual(firstMatch, expectedEmit)
    }

    public func testTokenizeTokensInSequence() {
        let trie = Trie.builder()
            .add(keyword: "Alpha")
            .add(keyword: "Beta")
            .add(keyword: "Gamma")
            .build()
        let tokens = trie.tokenize(text: "Alpha Beta Gamma")
        XCTAssertEqual(tokens.count, 5)
    }

    // Test offered by XCurry, https://github.com/robert-bor/aho-corasick/issues/7
    public func testZeroLengthRobertBorBug7InGithubReportedByXCurry() {
        let trie = Trie.builder().removeOverlaps().onlyDelimited().caseInsensitive()
            .add(keyword: "")
            .build()
        let text = "Try a natural lip and subtle bronzer to keep all the focus on those big bright eyes with NARS Eyeshadow Duo in Rated R And the winner is... Boots No7 Advanced Renewal Anti-ageing Glycolic Peel Kit ($25 amazon.com) won most-appealing peel."
        let tokens = trie.tokenize(text: text)
        //Check for stack overflow
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first?.fragment, text)
    }
    
    // Test offered by dwyerk, https://github.com/robert-bor/aho-corasick/issues/8
    public func testUnicodeIssueRobertBorBug8ReportedByDwyerk() {
        let target = "LİKE THIS" // The second character ('İ') is Unicode, which was read by AC as a 2-byte char
        
        let trie = Trie.builder().caseInsensitive().onlyDelimited()
            .add(keyword: "this")
            .build()
        let emits = trie.parse(text: target)
        XCTAssertEqual(emits.count, 1)
        
        XCTAssertEqual(emits.first, Emit(start: 5, end: 8, keyword: "this"))
    }
    
    public func testUnicodeIssueRobertBorBug8ReportedByDwyerkFirstMatch() {
        let target = "LİKE THIS" // The second character ('İ') is Unicode, which was read by AC as a 2-byte char
        let trie = Trie.builder()
            .caseInsensitive()
            .onlyDelimited()
            .add(keyword: "this")
            .build()
        let firstMatch = trie.firstMatch(text: target)
        let expectedEmit = Emit(start: 5, end: 8, keyword: "this")
        XCTAssertEqual(firstMatch, expectedEmit)
    }

    public func testUnicodeTR29Delimited() {
        let trie = Trie.builder()
            .onlyDelimited()
            .add(keyword: "abc")
            .build()

        let emits = trie.parse(text: "abc, abc: abc? abcabc ・abc・ 〱abc〴 〴abcd >abc")

        XCTAssertEqual(emits.count, 6)
        var iterator = emits.makeIterator()

        XCTAssertEqual(iterator.next(), Emit(start: 0, end: 2, keyword: "abc"))
        XCTAssertEqual(iterator.next(), Emit(start: 5, end: 7, keyword: "abc"))
        XCTAssertEqual(iterator.next(), Emit(start: 10, end: 12, keyword: "abc"))
        XCTAssertEqual(iterator.next(), Emit(start: 23, end: 25, keyword: "abc"))
        XCTAssertEqual(iterator.next(), Emit(start: 29, end: 31, keyword: "abc"))
        XCTAssertEqual(iterator.next(), Emit(start: 41, end: 43, keyword: "abc"))
        XCTAssertNil(iterator.next())
    }

    public func testHTML() {
        let speech = "The Answer to the Great Question... Of Life, " +
            "the Universe and Everything... Is... Forty-two,' said " +
        "Deep Thought, with infinite majesty and calm.";
        let trie = Trie.builder()
            .removeOverlaps()
            .onlyDelimited()
            .caseInsensitive()
            .add(keyword: "great question")
            .add(keyword: "forty-two")
            .add(keyword: "deep thought")
            .build()
        let tokens = trie.tokenize(text: speech)
        var html = ""
        html.append("<html><body><p>")
        for token in tokens {
            if token.isMatch {
                html.append("<i>")
            }
            html.append(token.fragment)
            if token.isMatch {
                html.append("</i>")
            }
        }
        html.append("</p></body></html>")

        let expectedHTML = "<html><body><p>The Answer to the <i>Great Question</i>... Of Life, the Universe and Everything... Is... <i>Forty-two</i>,\' said <i>Deep Thought</i>, with infinite majesty and calm.</p></body></html>"

        XCTAssertEqual(html, expectedHTML)
    }

    public func testDiacriticInsensitive() {
        let trie = Trie.builder()
            .diacriticInsensitive()
            .add(keyword: "café")
            .build()

        let matches = trie.containsMatch(text: "je bois du cafe tous les matins")

        XCTAssertTrue(matches)
    }

    public func testDiacriticInsensitiveCaseInsensitive() {
        let trie = Trie.builder()
        .diacriticInsensitive()
        .caseInsensitive()
        .add(keyword: "cafè")
        .build()

        let emits = trie.parse(text: "cafe cafè café cafë CafÉ cafÈ")

        XCTAssertEqual(emits.count, 6)
    }

    func assertContainsAll<T: Equatable>(expected: [T], actual: [T], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(expected.count, actual.count)
        expected.forEach { XCTAssertTrue(actual.contains($0)) }
    }
}
