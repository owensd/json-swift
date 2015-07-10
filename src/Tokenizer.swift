//
//  Tokenizer.swift
//  ParseKit
//
//  Created by David Owens on 6/18/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

import Foundation

public enum TokenizerError : ErrorType {
    case NoTokenizerRulesPresent
}

/// Represents an error that happens during the tokenization process.
public enum TokenizerErrorOf<T> : ErrorType {
    case Error(message: String, offset: T)
}

/// A token represents a meaningful item within the content stream.
public struct Token<ContentType where ContentType : ExtensibleCollectionType> {
    
    /// Create a new token with the starting and ending offsets within the content. The value of the token
    /// should also be cached.
    public init(content: ContentType, startOffset: ContentType.Index, endOffset: ContentType.Index) {
        self.content = content
        self.startOffset = startOffset
        self.endOffset = endOffset
    }

    /// The cached content that make up the token.
    public let content: ContentType
    
    /// The offset within the content stream the token starts at.
    public let startOffset: ContentType.Index
    
    /// The offset within the content stream the token ends at.
    public let endOffset: ContentType.Index
}

/// A `TokenizerResult` is the result of a tokenizer rule successfully being matched.
public struct TokenizerResult<ContentType where ContentType : ExtensibleCollectionType> {
    
    /// The token that was matched from a tokenizer rule.
    public let token: Token<ContentType>
    
    /// The next index in the content stream the next tokenizer rule should start matching from.
    public let nextIndex: ContentType.Index
    
    // BUG(http://openradar.appspot.com/21461071): Initializers are not generated in the public scope.
    public init(token: Token<ContentType>, nextIndex: ContentType.Index) {
        self.token = token
        self.nextIndex = nextIndex
    }
}

/// A rules based tokenizer that works over an content type that implements `ExtensibleCollectionType`.
public protocol Tokenizer {
    typealias ContentType : ExtensibleCollectionType

    var rules: [(content: ContentType, offset: ContentType.Index) -> ContentType.Index?] { get }
    var content: ContentType { get }

    init(content: ContentType)
    
    // HACK(owensd): This version is necessary because default parameters crash the compiler in Swift 2, beta 2.
    func next() throws -> TokenizerResult<ContentType>?
    func next(index: ContentType.Index?) throws -> TokenizerResult<ContentType>?
}

extension Tokenizer {
    public func next() throws -> TokenizerResult<ContentType>? {
        return try next(nil)
    }
    
    public func next(index: ContentType.Index?) throws -> TokenizerResult<ContentType>? {
        try assert(!rules.isEmpty, TokenizerError.NoTokenizerRulesPresent)
        try assert(!rules.isEmpty, "There are no rules specified for your tokenizer.", TokenizerError.NoTokenizerRulesPresent)


        let startAt = index ?? content.startIndex
        if startAt == content.endIndex { return nil }
        
        for rule in rules {
            if let nextIndex = rule(content: content, offset: startAt) {
                // TODO(owensd): Can we make this an extension ot ExtensibleCollectionType? The type is Self.ContentType._prext_SubSlice.
                var slice = ContentType.init()
                for n in startAt...nextIndex {
                    slice.append(content[n])
                }
                
                let token = Token(content: slice, startOffset: startAt, endOffset: nextIndex)
                return TokenizerResult(token: token, nextIndex: nextIndex.successor())
            }
        }
        
        throw TokenizerErrorOf.Error(message: "", offset: self.content.startIndex)
    }
}

extension ExtensibleCollectionType {
    init<S : Sliceable where S.Generator.Element == Generator.Element>(sequence: S) {
        self.init()
        
        for elem in sequence {
            self.append(elem)
        }
    }
}
