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
public struct Token<Content where Content : ExtensibleCollectionType> {
    typealias Index = Content.Index
    
    /// Create a new token with the starting and ending offsets within the content. The value of
    /// the token should also be cached.
    public init(content: Content, startOffset: Index, endOffset: Index) {
        self.content = content
        self.startOffset = startOffset
        self.endOffset = endOffset
    }

    /// The cached content that make up the token.
    public let content: Content
    
    /// The offset within the content stream the token starts at.
    public let startOffset: Index
    
    /// The offset within the content stream the token ends at.
    public let endOffset: Index
}

/// A `TokenizerResult` is the result of a tokenizer rule successfully being matched.
public struct TokenizerResult<Content where Content : ExtensibleCollectionType> {
    typealias Index = Content.Index
    
    /// The token that was matched from a tokenizer rule.
    public let token: Token<Content>
    
    /// The next index in the content stream the next tokenizer rule should start matching from.
    public let nextIndex: Index
    
    // BUG(http://openradar.appspot.com/21461071): Initializers are not generated as public.
    public init(token: Token<Content>, nextIndex: Index) {
        self.token = token
        self.nextIndex = nextIndex
    }
}

/// A rules based tokenizer that works over an content type that implements
/// `ExtensibleCollectionType`.
public protocol Tokenizer {
    typealias Content : ExtensibleCollectionType
    
    // Bug(http://www.openradar.me/21807845): This type does not match properly in extensions.
    // typealias Index = Content.Index

    // BUG(http://openradar.appspot.com/21571050): Generic typealiases are not supported. Once that
    // is fixed, then this can definition can be promoted out.
    
    /// The set of rules that a tokenizer should use in order to match tokens. This set of
    /// rules is shared across all instances of the tokenizer.
    static var rules: [(content: Content, offset: Content.Index) -> Content.Index?] { get }
    
    /// The content stream the tokenizer works over.
    var content: Content { get }

    init(content: Content)
    
    // BUG(https://twitter.com/jckarter/status/613709523144982529): Default parameters in protocols
    // crash the compiler... good times.
    func next() throws -> TokenizerResult<Content>?
    
    /// Attempts to find the next token based on the given starting `index`.
    ///
    /// - parameter index: The location to start the rules processing from. A value of `nil` is
    ///   used to denote starting from the beginning.
    func next(index: Content.Index?) throws -> TokenizerResult<Content>?
}

extension Tokenizer {
    public func next() throws -> TokenizerResult<Content>? {
        return try next(nil)
    }
    
    /// The default implementation calls each of the rules, in order, for the type passing in
    /// the content and the current value of `index`. The first rule that matches returns a
    /// `TokenizerResult` describing the matched result.
    ///
    /// - parameter index: The current index to start matching the rules from. If `nil` is given
    ///   then the search should start from the beginning of the content.
    public func next(index: Content.Index?) throws -> TokenizerResult<Content>? {
        try assert(!Self.rules.isEmpty, "There are no rules specified for your tokenizer.",
            TokenizerError.NoTokenizerRulesPresent)

        let startAt = index ?? content.startIndex
        if startAt == content.endIndex { return nil }
        
        for rule in Self.rules {
            if let nextIndex = rule(content: content, offset: startAt) {
                // TODO(owensd): Can we make this an extension ot ExtensibleCollectionType? The
                // type is Self.ContentType._prext_SubSlice.
                // I think this is blocked by bug http://www.openradar.me/21807845.
                var slice = Content.init()
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
