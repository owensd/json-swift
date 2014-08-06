//
//  JSON.swift
//  JSON
//
//  Created by David Owens on 6/20/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

import Foundation

/// A convenience type declaration for use with top-level JSON objects.
public typealias JSON = JSValue

/// The error domain for all `JSValue` related errors.
public let JSValueErrorDomain      = "com.kiadsoftware.json.error"

/// A representative type for all possible JSON values.
///
/// See http://json.org for a full description.
public enum JSValue : Equatable, Printable {
    
    /// The maximum integer that is safely representable in JavaScript.
    public static let MaximumSafeInt: Int = 9007199254740991
    
    /// The minimum integer that is safely representable in JavaScript.
    public static let MinimumSafeInt: Int = -9007199254740991
    
    /// All of the error codes when parsing JSON.
    public enum ErrorCodes: Int {
        /// A integer that is outside of the safe range was attempted to be set.
        case InvalidIntegerValue        = 1
        
        /// Error when converting a dictionary and the key is not of type `String`.
        case InvalidKeyType
        
        /// An unsupported type is attempting to be parsed.
        case UnsupportedType
        
        /// Error used when attempting to convert a value to an type it does not represent.
        case InvalidType
        
        /// Error used when attempting to convert a value to an type when the value is null.
        case NullValue
        
        /// Error used when attempting to retrieve a dictionary item with an invalid key.
        case InvalidKeyValue

        /// Error used when attempting to retrieve an array item with an invalid index.
        case InvalidIndexValue
    }
    
    
    /// Provides a set of all of the valid encoding types when using data that needs to be
    /// within the contents of a string value.
    public enum Encodings : String {
        case base64 = "data:text/plain;base64,"
    }

    ///
    /// MARK: The valid types representable in JSON
    ///
    
    case JSString(Swift.String)
    case JSNumber(Double)
    case JSObject([Swift.String : JSValue])
    case JSArray([JSValue])
    case JSBool(Swift.Bool)
    case JSNull
    
    /// This is a stop-gap until Swift supports initializers that can return error information.
    case Invalid(Error)
    
    /// Initializes a new `JSValue` with a `Bool`.
    public init(_ value: Bool) {
        self = .JSBool(value)
    }
    
    /// Initializes a new `JSValue` with a `Double`.
    public init(_ value: Double) {
        self = .JSNumber(value)
    }
    
    /// Initializes a new `JSValue` with an `Int`.
    public init(_ value: Int) {
        assert(value >= JSValue.MinimumSafeInt)
        assert(value <= JSValue.MaximumSafeInt)
        
        if (value < JSValue.MinimumSafeInt || value > JSValue.MaximumSafeInt) {
            let info = [LocalizedDescriptionKey: "Invalid integer value of '\(value)'. Integers must be within the range \(JSValue.MinimumSafeInt) and \(JSValue.MaximumSafeInt)"]
            self = .Invalid(Error(code: JSValue.ErrorCodes.InvalidIntegerValue.toRaw(), domain: JSValueErrorDomain, userInfo: info))
        }
        
        self = .JSNumber(Double(value))
    }
    
    /// Initializes a new `JSValue` with a `String`.
    public init(_ value: String) {
        self = .JSString(value)
    }
    
    /// Initializes a new `JSValue` with an `[JSValue]`.
    public init(_ value: [JSValue]) {
        self = .JSArray(value)
    }
    
    /// Initializes a new `JSValue` with a `[String: JSValue]`.
    public init(_ value: [String : JSValue]) {
        self = .JSObject(value)
    }
    
    /// Parses the given string and attempts to return a `JSValue` from it.
    ///
    /// :param: jsonString the string that contains the JSON to parse.
    ///
    /// :returns: A `FailableOf<T>` that will contain the parsed `JSValue` if successful,
    ///           otherwise, the `Error` information for the parsing.
    public static func parse(jsonString : String) -> FailableOf<JSValue> {
        var data = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)

        var error = NSErrorPointer()
        var jsonObject : AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: error)
        
        return jsonObject != nil ? FailableOf(JSValue(jsonObject)) : FailableOf(Error(error))
    }
    
    /// Attempts to convert the `JSValue` into its string representation.
    ///
    /// :param: indent the indent string to use; defaults to "  "
    ///
    /// :returns: A `FailableOf<T>` that will contain the `String` value if successful,
    ///           otherwise, the `Error` information for the conversion.
    public func stringify(indent: String = "  ") -> FailableOf<String> {
        switch self {
        case .Invalid(let error):
            return FailableOf(error)
            
        default:
            return FailableOf(prettyPrint(indent, 0))
        }
    }
    
    public var string : FailableOf<String> {
        switch self {
        case .Invalid(let error):
            return FailableOf(error)
            
        case .JSString(let string):
            return FailableOf(string)
            
        default:
            return FailableOf(Error(
                code: JSValue.ErrorCodes.InvalidType.toRaw(),
                domain: JSValueErrorDomain,
                userInfo: [LocalizedDescriptionKey: "The specified value is not of type 'String'."]))
        }
    }
    
    public var number : FailableOf<Double> {
        switch self {
        case .Invalid(let error):
            return FailableOf(error)
            
        case .JSNumber(let double):
            return FailableOf(double)
            
        default:
            return FailableOf(Error(
                code: JSValue.ErrorCodes.InvalidType.toRaw(),
                domain: JSValueErrorDomain,
                userInfo: [LocalizedDescriptionKey: "The specified value is not of type 'Double'."]))
        }
    }
    
    public var object : FailableOf<[String:JSValue]> {
        switch self {
        case .Invalid(let error):
            return FailableOf(error)
            
        case .JSObject(let object):
            return FailableOf(object)
            
        default:
            return FailableOf(Error(
                code: JSValue.ErrorCodes.InvalidType.toRaw(),
                domain: JSValueErrorDomain,
                userInfo: [LocalizedDescriptionKey: "The specified value is not of type '[String:JSValue]'."]))
        }
    }
    
    public var array : FailableOf<[JSValue]> {
        switch self {
        case .Invalid(let error):
            return FailableOf(error)
            
        case .JSArray(let array):
            return FailableOf(array)
            
        default:
            return FailableOf(Error(
                code: JSValue.ErrorCodes.InvalidType.toRaw(),
                domain: JSValueErrorDomain,
                userInfo: [LocalizedDescriptionKey: "The specified value is not of type '[JSValue]'."]))
        }
    }
    
    public var bool : FailableOf<Bool> {
        switch self {
        case .Invalid(let error):
            return FailableOf(error)
            
        case .JSBool(let bool):
            return FailableOf(bool)
            
        default:
            return FailableOf(Error(
                code: JSValue.ErrorCodes.InvalidType.toRaw(),
                domain: JSValueErrorDomain,
                userInfo: [LocalizedDescriptionKey: "The specified value is not of type 'Bool'."]))
        }
    }
    
    /// Returns the raw dencoded bytes of the value that was stored in the `string` value.
    public var decodedString: [Byte]? {
        switch self {
        case .JSString(let encodedStringWithPrefix):
            if encodedStringWithPrefix.hasPrefix(Encodings.base64.toRaw()) {
                let encodedString = encodedStringWithPrefix.stringByReplacingOccurrencesOfString(Encodings.base64.toRaw(), withString: "")
                let decoded = NSData(base64EncodedString: encodedString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                
                let bytesPointer = UnsafePointer<Byte>(decoded.bytes)
                let bytes = UnsafeBufferPointer<Byte>(start: bytesPointer, length: decoded.length)
                return [Byte](bytes)
            }
            
        default:
            return nil
        }
            
        return nil
    }

    /// Attempts to treat the `JSValue` as a dictionary and return the item with the given key.
    public subscript(key: String) -> JSValue {
        get {
            switch self {
            case .JSObject(let dict):
                if let result = dict[key] {
                    return result
                } else {
                    let error = Error(
                        code: JSValue.ErrorCodes.InvalidKeyValue.toRaw(),
                        domain: JSValueErrorDomain,
                        userInfo: [LocalizedDescriptionKey: "There is no value stored with key: '\(key)'."])
                    return JSValue.Invalid(error)
                }
                
            default:
                let error = Error(
                    code: JSValue.ErrorCodes.InvalidType.toRaw(),
                    domain: JSValueErrorDomain,
                    userInfo: [LocalizedDescriptionKey: "Cannot index by string on a non-dictionary value."])
                return JSValue.Invalid(error)
            }
        }
        set {
            if var dict = self.object.value {
                dict[key] = newValue
                self = JSValue(dict)
            }
        }
    }

    /// Attempts to treat the `JSValue` as an array and return the item at the index.
    public subscript(index: Int) -> JSValue {
        get {
            switch self {
            case .JSArray(let array):
                if index < 0 || index >= array.count {
                    let error = Error(
                        code: JSValue.ErrorCodes.InvalidIndexValue.toRaw(),
                        domain: JSValueErrorDomain,
                        userInfo: [LocalizedDescriptionKey: "The index (\(index)) is not valid for the range [0, \(array.count))."])
                    return JSValue.Invalid(error)
                }

                return array[index]
                
            default:
                let error = Error(
                    code: JSValue.ErrorCodes.InvalidType.toRaw(),
                    domain: JSValueErrorDomain,
                    userInfo: [LocalizedDescriptionKey: "Cannot index into a non-array value."])
                return JSValue.Invalid(error)
            }
        }
        set {
            if var array = self.array.value {
                array[index] = newValue
                self = JSValue(array)
            }
        }
    }
    
    /// Prints out the description of the JSValue value as pretty-printed JSValue.
    public var description: String {
        if let string = stringify().value {
            return string
        }
        else {
            return "<INVALID JSON>"
        }
    }
}

public func ==(lhs: JSValue, rhs: JSValue) -> Bool {
    switch (lhs, rhs) {
    case (.JSNull, .JSNull):
        return true
        
    case (.JSBool(let lhsValue), .JSBool(let rhsValue)):
        return lhsValue == rhsValue

    case (.JSString(let lhsValue), .JSString(let rhsValue)):
        return lhsValue == rhsValue

    case (.JSNumber(let lhsValue), .JSNumber(let rhsValue)):
        return lhsValue == rhsValue

    case (.JSArray(let lhsValue), .JSArray(let rhsValue)):
        return lhsValue == rhsValue

    case (.JSObject(let lhsValue), .JSObject(let rhsValue)):
        return lhsValue == rhsValue
        
    default:
        return false
    }
}

//
// MARK: Convenience extensions, including ObjC interop.
//
extension JSValue {
    
    /// :returns: `true` if the `JSValue` is not invalid, `false` otherwise.
    public var hasValue: Bool {
        switch self {
        case .Invalid(_):
            return false
            
        default:
            return true
        }
    }
    
    /// :returns: The `Error` instance for the invalid state of the `JSValue`.
    public var error: Error? {
        switch self {
        case .Invalid(let error):
            return error
            
        default:
            return nil
        }
    }
    
    /// Initializes a new `JSValue` with a `[Byte]`.
    public init(_ bytes: [Byte], encoding: Encodings = Encodings.base64) {
        let data = NSData(bytes: bytes, length: bytes.count)
        self.init(data, encoding: encoding)
    }

    /// Initializes a new `JSValue` with a `[Byte]`.
    public init(_ data: NSData, encoding: Encodings = Encodings.base64) {
        switch encoding {
        case .base64:
            let encoded = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding76CharacterLineLength)
            self = .JSString("\(encoding.toRaw())\(encoded)")
        }
    }

    /// Initializes a new `JSValue` from an `AnyObject?`. If a failure occurs, the `JSValue` will be `Invalid`.
    public init(_ rawValue: AnyObject?) {
        if let value : AnyObject = rawValue {
            switch value {
            case let array as NSArray:
                var newArray = [JSValue]()
                for item : AnyObject in array {
                    newArray += [JSValue(item)]
                }
                self = .JSArray(newArray)
                
            case let dict as NSDictionary:
                var newDict = [String : JSValue]()
                for (k : AnyObject, v : AnyObject) in dict {
                    if let key = k as? String {
                        newDict[key] = JSValue(v)
                    }
                    else {
                        let info = [LocalizedDescriptionKey: "Invalid key type; expected String"]
                        let error = Error(code: JSValue.ErrorCodes.InvalidKeyType.toRaw(), domain: JSValueErrorDomain, userInfo: info)
                        self = .Invalid(error)
                        return
                    }
                }
                self = .JSObject(newDict)
                
            case let string as NSString:
                self = .JSString(string)
                
            case let number as NSNumber:
                if String.fromCString(number.objCType) == "c" {
                    self = .JSBool(number.boolValue)
                }
                else {
                    self = .JSNumber(number.doubleValue)
                }
                
            case let null as NSNull:
                self = .JSNull
                
            default:
                let info = [LocalizedDescriptionKey: "Unsupported JSON type attempting to be serialized."]
                let error = Error(code: JSValue.ErrorCodes.UnsupportedType.toRaw(), domain: JSValueErrorDomain, userInfo: info)
                self = .Invalid(error)
            }
        }
        else {
            self = .JSNull
        }
    }
}

extension JSValue {
    func prettyPrint(indent: String, _ level: Int) -> String {
        let currentIndent = join(indent, map(0...level, { (item: Int) in "" }))
        let nextIndent = currentIndent + "  "
        
        switch self {
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
            
        case .Invalid(_):
            assert(false, "This should never be reached")
            return ""
        }
    }
}

//
// MARK: Literal Convertibles to allow in-place boxing from literal values.
//

extension JSValue : IntegerLiteralConvertible {
    public static func convertFromIntegerLiteral(value: Int) -> JSValue {
        return .JSNumber(Double(value))
    }
}

extension JSValue : FloatLiteralConvertible {
    public static func convertFromFloatLiteral(value: Double) -> JSValue {
        return .JSNumber(value)
    }
}

extension JSValue : StringLiteralConvertible {
    public static func convertFromStringLiteral(value: String) -> JSValue {
        return .JSString(value)
    }
    public static func convertFromExtendedGraphemeClusterLiteral(value: String) -> JSValue {
        return .JSString(value)
    }
}

extension JSValue : ArrayLiteralConvertible {
    public static func convertFromArrayLiteral(elements: JSValue...) -> JSValue {
        return .JSArray(elements)
    }
}

extension JSValue : DictionaryLiteralConvertible {
    public static func convertFromDictionaryLiteral(elements: (String, JSValue)...) -> JSValue {
        var dict = [String : JSValue]()
        for (k, v) in elements {
            dict[k] = v
        }
        
        return .JSObject(dict)
    }
}

extension JSValue : NilLiteralConvertible {
    public static func convertFromNilLiteral() -> JSValue {
        return JSNull
    }
}

extension JSValue: BooleanLiteralConvertible {
    public static func convertFromBooleanLiteral(value: BooleanLiteralType) -> JSValue {
        return JSBool(value)
    }
}
