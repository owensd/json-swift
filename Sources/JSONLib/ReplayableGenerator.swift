/* --------------------------------------------------------------------------------------------
 * Copyright (c) Kiad Studios, LLC. All rights reserved.
 * Licensed under the MIT License. See License in the project root for license information.
 * ------------------------------------------------------------------------------------------ */

/// Creates a `GeneratorType` that is able to "replay" its previous value on the next `next()` call.
/// Useful for generator sequences in which you need to simply step-back a single element.
public final class ReplayableGenerator<S: Sequence> : IteratorProtocol, Swift.Sequence {
    public typealias Sequence = S
    public typealias Element = Sequence.Iterator.Element
    
    var firstRun = true
    var usePrevious = false
    var previousElement: Element? = nil
    var generator: Sequence.Iterator
    
    /// Initializes a new `ReplayableGenerator<S>` with an underlying `SequenceType`.
    /// - parameter sequence: the sequence that will be used to traverse the content.
    public init(_ sequence: S) {
        self.generator = sequence.makeIterator()
    }
    
    /// Moves the current element to the next element in the collection, if one exists.
    /// :return: The `current` element or `nil` if the element does not exist.
    public func next() -> Element? {
        switch usePrevious {
        case true:
            usePrevious = false
            return previousElement
            
        default:
            previousElement = generator.next()
            return previousElement
        }
    }
    
    /// Ensures that the next call to `next()` will use the current value.
    public func replay() {
        usePrevious = true
        return
    }
    
    /// Creates a generator that can be used to traversed the content. Each call to
    /// `generate` will call `replay()`.
    ///
    /// :return: A iteratable collection backing the content.
    public func makeIterator() -> ReplayableGenerator {
        switch firstRun {
        case true: firstRun = false
        default: self.replay()
        }

        return self
    }
    
    /// Determines if the generator is at the end of the collection's content.
    ///
    /// :return: `true` if there more content in the collection to view, `false` otherwise.
    public func atEnd() -> Bool {
        let element = next()
        replay()
        
        return element == nil
    }
}
