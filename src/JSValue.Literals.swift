//
//  JSON.literals.swift
//  JSON
//
//  Created by David Owens II on 8/11/14.
//  Copyright (c) 2014 David Owens II. All rights reserved.
//

import Foundation

extension JSValue : IntegerLiteralConvertible {
    private static func convert(value: Int) -> JSValue {
        if Int64(value) < JSValue.MinimumSafeInt || Int64(value) > JSValue.MaximumSafeInt {
            
            let error = Error(
                code: JSValue.ErrorCode.InvalidIntegerValue.code,
                domain: JSValueErrorDomain,
                userInfo: [ErrorKeys.LocalizedDescription: "\(ErrorCode.InvalidIntegerValue.message) Value: \(value)"])
            
            return JSValue(error)
        }
        return JSValue(Double(value))
    }

    public static func convertFromIntegerLiteral(value: Int) -> JSValue {
        return JSValue.convert(value)
    }
}

extension JSValue : FloatLiteralConvertible {
    public static func convertFromFloatLiteral(value: Double) -> JSValue {
        return JSValue(value)
    }
}


extension JSValue : StringLiteralConvertible {
    public static func convertFromStringLiteral(value: String) -> JSValue {
        return JSValue(value)
    }
    public static func convertFromExtendedGraphemeClusterLiteral(value: String) -> JSValue {
        return JSValue(value)
    }
	public static func convertFromUnicodeScalarLiteral(value: String) -> JSValue {
		return JSValue(value)
	}
}

extension JSValue : ArrayLiteralConvertible {
    public static func convertFromArrayLiteral(elements: JSValue...) -> JSValue {
        return JSValue(elements)
    }
}

extension JSValue : DictionaryLiteralConvertible {
    public static func convertFromDictionaryLiteral(elements: (String, JSValue)...) -> JSValue {
        var dict = JSObjectType()
        for (k, v) in elements {
            dict[k] = v
        }
        
        return JSValue(dict)
    }
}

extension JSValue : NilLiteralConvertible {
    public static func convertFromNilLiteral() -> JSValue {
        return JSValue(JSBackingValue.JSNull)
    }
}

extension JSValue: BooleanLiteralConvertible {
    public static func convertFromBooleanLiteral(value: BooleanLiteralType) -> JSValue {
        return JSValue(value)
    }
}
