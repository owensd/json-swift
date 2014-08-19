//
//  GeneratorBuffer.swift
//  JSON
//
//  Created by David Owens II on 8/19/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

/// Creates a buffered `GeneratorType` that allows access into the current value.
public struct BufferedGenerator<T: GeneratorType> : GeneratorType {
    typealias Generator = T
    
    var generator: Generator
    
    /// The current value the generator is currently on.
    public var current: Generator.Element? = nil
    
    /// Initializes a new `BufferedGenerator<T>` with an underlying `GeneratorType`.
    ///
    /// :param: generator The generator that will be used to traverse the content.
    public init(inout _ generator: Generator) {
        self.generator = generator
    }
    
    /// Moves the `current` element to the next element if one exists.
    ///
    /// :return: The `current` element or `nil` if the element does not exist.
    public mutating func next() -> Generator.Element? {
        self.current = generator.next()
        return self.current
    }
}
