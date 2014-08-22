//
//  JSON.swift
//  JSON
//
//  Created by David Owens on 6/20/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

/// A convenience type declaration for use with top-level JSON objects.
public typealias JSON = JSValue

/// The error domain for all `JSValue` related errors.
public let JSValueErrorDomain      = "com.kiadsoftware.json.error"

/// A representative type for all possible JSON values.
///
/// See http://json.org for a full description.
public struct JSValue : Equatable {

    /// The maximum integer that is safely representable in JavaScript.
    public static let MaximumSafeInt: Int64 = 9007199254740991
    
    /// The minimum integer that is safely representable in JavaScript.
    public static let MinimumSafeInt: Int64 = -9007199254740991


    /// The type of the underlying `JSArray`.
    public typealias JSArrayType       = [JSValue]

    /// The type of the underlying `JSObject`.
    public typealias JSObjectType      = [String:JSValue]
    
    /// The type of the underlying `JSString`.
    public typealias JSStringType      = String

    /// The type of the underlying `JSNumber`.
    public typealias JSNumberType      = Double

    /// The type of the underlying `JSBool`.
    public typealias JSBoolType        = Bool

    /// The underlying value for `JSValue`.
    var value: JSBackingValue
    
    
    /// All of the possible values that a `JSValue` can hold.
    enum JSBackingValue {
        /*
         * Implementation Note:
         *
         * I do not want consumers to be able to simply do JSValue.JSNumber(123) as I need to perform
         * validation on the input. This prevents me from simply using an enum. Thus I have this
         * strange nested enum to store the values. I'm not sure I like this approach, but I do not
         * see a better one at the moment...
         */
        
        /// Holds an array of JavaScript values that conform to valid `JSValue` types.
        case JSArray([JSValue])

        /// Holds an unordered set of key/value pairs conforming to valid `JSValue` types.
        case JSObject([String : JSValue])

        /// Holds the value conforming to JavaScript's String object.
        case JSString(String)
        
        /// Holds the value conforming to JavaScript's Number object.
        case JSNumber(Double)
        
        /// Holds the value conforming to JavaScript's Boolean wrapper.
        case JSBool(Bool)
        
        /// Holds the value that corresponds to `null`.
        case JSNull
        
        /// Holds the error information when the `JSValue` could not be made into a valid item.
        case Invalid(Error)
    }

    
    /// Initializes a new `JSValue` with a `JSArrayType` value.
    public init(_ value: JSArrayType) {
        self.value = JSBackingValue.JSArray(value)
    }

    /// Initializes a new `JSValue` with a `JSObjectType` value.
    public init(_ value: JSObjectType) {
        self.value = JSBackingValue.JSObject(value)
    }

    /// Initializes a new `JSValue` with a `JSStringType` value.
    public init(_ value: JSStringType) {
        self.value = JSBackingValue.JSString(value)
    }

    /// Initializes a new `JSValue` with a `JSNumberType` value.
    public init(_ value: JSNumberType) {
        self.value = JSBackingValue.JSNumber(value)
    }

    /// Initializes a new `JSValue` with a `JSBoolType` value.
    public init(_ value: JSBoolType) {
        self.value = JSBackingValue.JSBool(value)
    }

    /// Initializes a new `JSValue` with an `Error` value.
    init(_ error: Error) {
        self.value = JSBackingValue.Invalid(error)
    }

    /// Initializes a new `JSValue` with a `JSBackingValue` value.
    init(_ value: JSBackingValue) {
        self.value = value
    }
}

extension JSValue : Printable {
    
    /// Attempts to convert the `JSValue` into its string representation.
    ///
    /// :param: indent the indent string to use; defaults to "  "
    ///
    /// :returns: A `FailableOf<T>` that will contain the `String` value if successful,
    ///           otherwise, the `Error` information for the conversion.
    public func stringify(indent: String = "  ") -> String {
        return prettyPrint(indent, 0)
    }
    
    /// Prints out the description of the JSValue value as pretty-printed JSValue.
    public var description: String {
        return stringify()
    }
}

/// Used to compare two `JSValue` values.
///
/// :returns: `True` when `hasValue` is `true` and the underlying values are the same; `false` otherwise.
public func ==(lhs: JSValue, rhs: JSValue) -> Bool {
    switch (lhs.value, rhs.value) {
    case (.JSNull, .JSNull):
        return true
        
    case let (.JSBool(lhsValue), .JSBool(rhsValue)):
        return lhsValue == rhsValue

    case let (.JSString(lhsValue), .JSString(rhsValue)):
        return lhsValue == rhsValue

    case let (.JSNumber(lhsValue), .JSNumber(rhsValue)):
        return lhsValue == rhsValue

    case let (.JSArray(lhsValue), .JSArray(rhsValue)):
        return lhsValue == rhsValue

    case let (.JSObject(lhsValue), .JSObject(rhsValue)):
        return lhsValue == rhsValue
        
    default:
        return false
    }
}

extension JSValue {
    func prettyPrint(indent: String, _ level: Int) -> String {
        let currentIndent = join(indent, map(0...level, { (item: Int) in "" }))
        let nextIndent = currentIndent + "  "
        
        switch self.value {
        case .JSBool(let bool):
            return bool ? "true" : "false"
            
        case .JSNumber(let number):
            return "\(number)"
            
        case .JSString(let string):
            return "\"\(string)\""
            
        case .JSArray(let array):
            return "[\n" + join(",\n", array.map({ "\(nextIndent)\($0.prettyPrint(indent, level + 1))" })) + "\n\(currentIndent)]"
            
        case .JSObject(let dict):
            return "{\n" + join(",\n", map(dict, { "\(nextIndent)\"\($0)\" : \($1.prettyPrint(indent, level + 1))"})) + "\n\(currentIndent)}"
            
        case .JSNull:
            return "null"
            
        case .Invalid(let error):
            return "<Invalid JSON: \(error.description)>"
            
        }
    }
}
