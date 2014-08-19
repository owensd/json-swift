//
//  GeneratorBuffer.swift
//  JSON
//
//  Created by David Owens II on 8/19/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

/// Creates a buffered `GeneratorType` that allows access into the current value.
public struct BufferedGenerator<S: SequenceType> : GeneratorType {
    typealias Sequence = S
    
    var store: BackingGeneratorStore<Sequence>
    
    /// The current value the generator is currently on.
    public var current: Sequence.Generator.Element? = nil
    
    /// Initializes a new `BufferedGenerator<T>` with an underlying `SequenceType`.
    ///
    /// :param: sequence the sequence that will be used to traverse the content.
    public init(_ sequence: Sequence) {
        self.store = BackingGeneratorStore(sequence)
    }
    
    /// Moves the `current` element to the next element if one exists.
    ///
    /// :return: The `current` element or `nil` if the element does not exist.
    public mutating func next() -> Sequence.Generator.Element? {
        self.current = store.generator.next()
        return self.current
    }
}


/// Stores the generator instance to ensure that copies of `BufferedGenerator<S>` do
/// not also copy the backing `generator` instance. This is because of the following
/// comment for `GeneratorType`:
///  > "While it is safe to copy a `GeneratorType`, only one copy should be advanced with `next()`."
final class BackingGeneratorStore<S: SequenceType> {
    var generator: S.Generator
    init(_ sequence: S) { self.generator = sequence.generate() }
}