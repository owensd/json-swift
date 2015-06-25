//
//  ParseKitTests.swift
//  ParseKitTests
//
//  Created by David Owens on 6/18/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

import XCTest
import ParseKit

class ParseKitTests: XCTestCase {
    
    func testTokenizerThrowsWithNoRules() {
        let rules: [TokenizerRule] = []
        let content = "let foo = 12"
        
        let tokenizer = Tokenizer(rules: rules, content: content)
        XCTAssertDoesThrow(try tokenizer.next())
    }

    func testTokenizerThrowsWithNoMatchingRules() {
        func matchOnWordDog(content: TokenizerString, offset: TokenizerIndex) -> TokenizerIndex? {
            if offset != content.endIndex && content[offset] == "d" {
                let next = offset.successor()
                if next != content.endIndex && content[next] == "o" {
                    let next = offset.successor()
                    if next != content.endIndex && content[next] == "g" {
                        return next
                    }
                }
            }
            
            return nil
        }

        let rules: [TokenizerRule] = [matchOnWordDog]
        let content = "let foo = 12"
        
        let tokenizer = Tokenizer(rules: rules, content: content)
        XCTAssertDoesThrow(try tokenizer.next())
    }

    func testTokenizerMatchesDogThrowsWithNoMatchingRules() {
        func matchOnWordDog(content: TokenizerString, offset: TokenizerIndex) -> TokenizerIndex? {
            if offset != content.endIndex && content[offset] == "d" {
                let next = offset.successor()
                if next != content.endIndex && content[next] == "o" {
                    let next = next.successor()
                    if next != content.endIndex && content[next] == "g" {
                        return next
                    }
                }
            }
            
            return nil
        }
        
        let rules: [TokenizerRule] = [matchOnWordDog]
        let content = "dog cat"
        
        let tokenizer = Tokenizer(rules: rules, content: content)
        
        do {
            let token = try tokenizer.next()
            XCTAssertNotNil(token)
            XCTAssertEqual(token!.token, "dog")
        }
        catch {
            XCTFail()
        }

        XCTAssertDoesThrow(try tokenizer.next())
    }
    
    
    func testCSVTokenizer() {
//        let csv = "fname,lname,age\ndavid,owens,33"
//        
//        var tokens = [Character:TokenHandler]()
//        tokens[","] = { cs, idx, ontoken in
//            var content = ""
//            var characters = cs
//            var index = idx
//            
//            iterator: while index != characters.endIndex {
//                let c = characters[index]
//                switch c {
//                case ",", "\n":
//                    ontoken(token: Token(token: Character(" "), content: content, column: 0, line: 0))
//                    break iterator
//                    
//                case "\r":
//                    ++index
//                    
//                default:
//                    content.append(c)
//                    ++index
//                }
//            }
//        
//            return index
//        }
//        tokens["\n"] = tokens[","]
//        
//        var tokensHit = 0
//        
//        let tokenizer = Tokenizer(content: csv, tokens: tokens) {
//            ++tokensHit
//            print("token: \($0.token), content: \($0.content) @ (\($0.column), \($0.line))")
//        }
//        
//        XCTAssertDoesNotThrow(try tokenizer.tokenize(Character(",")), message: "Parsing a trivial CSV file should not throw...")
//        XCTAssertEqual(tokensHit, 10)
    }
    
    func testJSONTokenizer() {
        
    }
    
}
