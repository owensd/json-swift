//
//  JSON.literals.swift
//  JSON
//
//  Created by David Owens II on 8/11/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

import Foundation

extension JSValue : IntegerLiteralConvertible {
    private static func convert(value: Int) -> JSValue {
        if Int64(value) < JSValue.MinimumSafeInt || Int64(value) > JSValue.MaximumSafeInt {
            
            let error = Error(
                code: JSValue.ErrorCode.InvalidIntegerValue.code,
                domain: JSValueErrorDomain,
                userInfo: [ErrorKeys.LocalizedDescription: "\(ErrorCode.InvalidIntegerValue.message) Value: \(value)"])
            
            return JSValue(JSBackingValue.Invalid(error))
        }
        return JSValue(JSBackingValue.JSNumber(Double(value)))
    }

    public static func convertFromIntegerLiteral(value: Int) -> JSValue {
        return JSValue.convert(value)
    }
}

extension JSValue : FloatLiteralConvertible {
    public static func convertFromFloatLiteral(value: Double) -> JSValue {
        return JSValue(JSBackingValue.JSNumber(value))
    }
}


extension JSValue : StringLiteralConvertible {
    public static func convertFromStringLiteral(value: String) -> JSValue {
        return JSValue(JSBackingValue.JSString(value))
    }
    public static func convertFromExtendedGraphemeClusterLiteral(value: String) -> JSValue {
        return JSValue(JSBackingValue.JSString(value))
    }
}

extension JSValue : ArrayLiteralConvertible {
    public static func convertFromArrayLiteral(elements: JSValue...) -> JSValue {
        return JSValue(JSBackingValue.JSArray(elements))
    }
}

extension JSValue : DictionaryLiteralConvertible {
    public static func convertFromDictionaryLiteral(elements: (String, JSValue)...) -> JSValue {
        var dict = [String : JSValue]()
        for (k, v) in elements {
            dict[k] = v
        }
        
        return JSValue(JSBackingValue.JSObject(dict))
    }
}

extension JSValue : NilLiteralConvertible {
    public static func convertFromNilLiteral() -> JSValue {
        return JSValue(JSBackingValue.JSNull)
    }
}

extension JSValue: BooleanLiteralConvertible {
    public static func convertFromBooleanLiteral(value: BooleanLiteralType) -> JSValue {
        return JSValue(JSBackingValue.JSBool(value))
    }
}

// These are technically not supported, but are extremely useful. Hopefully Swift v1.0 will have an 'official'
// way of representing this.

extension Int {
    /// Converts an `Int` to a `JSValue`.
    public func __conversion() -> JSValue {
        return JSValue.convert(self)
    }
}

extension Double {
    /// Converts a `Double` to a `JSValue`.
    public func __conversion() -> JSValue {
        return JSValue(JSValue.JSBackingValue.JSNumber(self))
    }
}

extension String {
    /// Converts a `String` to a `JSValue`.
    public func __conversion() -> JSValue {
        return JSValue(JSValue.JSBackingValue.JSString(self))
    }
}