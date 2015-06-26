//
//  Tokenizer.swift
//  ParseKit
//
//  Created by David Owens on 6/18/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

import Foundation

public enum TokenizerError<T> : ErrorType {
    case Error(message: String, offset: T)
}

public struct Token<ContentType where ContentType : CollectionType> {
    
    public init(token: ContentType, startOffset: ContentType.Index, endOffset: ContentType.Index) {
        self.token = token
        self.startOffset = startOffset
        self.endOffset = endOffset
    }

    public let token: ContentType
    public let startOffset: ContentType.Index
    public let endOffset: ContentType.Index
}

public struct TokenizerResult<ContentType where ContentType : CollectionType> {
    public let token: Token<ContentType>
    public let nextIndex: ContentType.Index
    
    public init(token: Token<ContentType>, nextIndex: ContentType.Index) {
        self.token = token
        self.nextIndex = nextIndex
    }
}

public protocol TokenizerType {
    typealias ContentType : CollectionType
    
    var rules: [(content: ContentType, offset: ContentType.Index) -> ContentType.Index?] { get }
    var content: ContentType { get }

    init(content: ContentType)
    
    // HACK(owensd): This version is necessary because default parameters crash the compiler in Swift 2, beta 2.
    func next() throws -> TokenizerResult<ContentType>?
    func next(index: ContentType.Index?) throws -> TokenizerResult<ContentType>?
}

extension TokenizerType {
    public func next() throws -> TokenizerResult<ContentType>? {
        return try next(nil)
    }
    
    public func next(index: ContentType.Index?) throws -> TokenizerResult<ContentType>? {
        precondition(rules.count > 0, "There are no rules specified for your tokenizer.")
        
        let startAt = index ?? content.startIndex
        
        for rule in rules {
            if let nextIndex = rule(content: content, offset: startAt) {
                // TODO(owensd): How to convert the content to a proper subset of it? Are we duplicating
                // this content all over the place now?
                let token = Token(token: content, startOffset: startAt, endOffset: nextIndex)
                return TokenizerResult(token: token, nextIndex: nextIndex.successor())
            }
        }
        
        throw TokenizerError.Error(message: "", offset: self.content.startIndex)
    }
}
