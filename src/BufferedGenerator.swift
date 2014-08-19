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
    
    var generator: Sequence.Generator
    
    /// The current value the generator is currently on.
    public var current: Sequence.Generator.Element? = nil
    
    /// Initializes a new `BufferedGenerator<T>` with an underlying `SequenceType`.
    ///
    /// :param: sequence the sequence that will be used to traverse the content.
    public init(_ sequence: Sequence) {
        self.generator = sequence.generate()
    }
    
    /// Moves the `current` element to the next element if one exists.
    ///
    /// :return: The `current` element or `nil` if the element does not exist.
    public mutating func next() -> Sequence.Generator.Element? {
        self.current = generator.next()
        return self.current
    }
}
