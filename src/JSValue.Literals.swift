//
//  JSON.literals.swift
//  JSON
//
//  Created by David Owens II on 8/11/14.
//  Copyright (c) 2014 David Owens II. All rights reserved.
//

import Foundation

extension JSValue : IntegerLiteralConvertible {
    private static func convert(value: Int64) -> JSValue {
        if value < JSValue.MinimumSafeInt || value > JSValue.MaximumSafeInt {
            
            let error = Error(
                code: JSValue.ErrorCode.InvalidIntegerValue.code,
                domain: JSValueErrorDomain,
                userInfo: [ErrorKeys.LocalizedDescription: "\(ErrorCode.InvalidIntegerValue.message) Value: \(value)"])
            
            return JSValue(error)
        }
        return JSValue(Double(value))
    }

    public init(integerLiteral value: Int64) {
        self = JSValue.convert(value)
    }
}

extension JSValue : FloatLiteralConvertible {
    public init(floatLiteral value: Double) {
        self = JSValue(value)
    }
}

extension JSValue : StringLiteralConvertible {
    public init(stringLiteral value: String) {
        self = JSValue(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self = JSValue(value)
    }
	
    public init(unicodeScalarLiteral value: String) {
		self = JSValue(value)
	}
}

extension JSValue : ArrayLiteralConvertible {
    public init(arrayLiteral elements: JSValue...) {
        self = JSValue(elements)
    }
}

extension JSValue : DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (String, JSValue)...) {
        var dict = JSObjectType()
        for (k, v) in elements {
            dict[k] = v
        }
        
        self = JSValue(dict)
    }
}

extension JSValue : NilLiteralConvertible {
    public init(nilLiteral: ()) {
        self = JSValue(JSBackingValue.JSNull)
    }
}

extension JSValue: BooleanLiteralConvertible {
    public init(booleanLiteral value: Bool) {
        self = JSValue(value)
    }
}
