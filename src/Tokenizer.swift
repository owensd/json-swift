//
//  Tokenizer.swift
//  ParseKit
//
//  Created by David Owens on 6/18/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

import Foundation

public typealias TokenizerString = String.CharacterView
public typealias TokenizerIndex = String.CharacterView.Index

public enum TokenizerError : ErrorType {
    case Error(message: String, offset: TokenizerIndex)
}

public struct Token {
    public init(token: String, startOffset: TokenizerIndex, endOffset: TokenizerIndex) {
        self.token = token
        self.startOffset = startOffset
        self.endOffset = endOffset
    }

    public let token: String
    public let startOffset: TokenizerIndex
    public let endOffset: TokenizerIndex
}

public typealias TokenizerRule = (content: TokenizerString, offset: TokenizerIndex) -> TokenizerIndex?

public struct Tokenizer {
    public var rules: [TokenizerRule]
    public var content: String
    
    var scratch: ScratchPad
    
    class ScratchPad {
        var currentIndex: TokenizerIndex
        init(currentIndex: TokenizerIndex) {
            self.currentIndex = currentIndex
        }
    }
    
    public init(rules: [TokenizerRule], content: String) {
        self.rules = rules
        self.content = content
        self.scratch = ScratchPad(currentIndex: self.content.startIndex)
    }
    
    public func next() throws -> Token? {
        if scratch.currentIndex == content.characters.endIndex { return nil }
        
        for rule in rules {
            if let nextIndex = rule(content: content.characters, offset: scratch.currentIndex) {
                let tokenString = String(content.characters[scratch.currentIndex...nextIndex])

                scratch.currentIndex = nextIndex.successor()
                return Token(token: tokenString, startOffset: scratch.currentIndex, endOffset: nextIndex)
            }
        }
        
        throw TokenizerError.Error(message: "", offset: self.content.characters.startIndex)
    }
}
