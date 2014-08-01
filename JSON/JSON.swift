//
//  JSON.swift
//  JSON
//
//  Created by David Owens on 6/20/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

import Foundation

// Alias to make using a JSON structure for a single value more natural.
public typealias JSONValue = JSON

// Special handling for "null" as there seems to be no good way to do JSONValue(nil) for all types
public let JSONNull = JSONValue.JSONNull

/// A representative type for all possible JSON values.
///
/// See http://json.org for a full description.
public enum JSON : Equatable, Printable {
    
    /// Provides a set of all of the valid encoding types when using data that needs to be 
    /// within the contents of a string value.
    public enum Encodings : String {
        case base64 = "data:text/plain;base64,"
    }
    
    /// All of the possible values representable by JSON.
    
    case JSONString(Swift.String)
    case JSONNumber(Double)
    case JSONObject([String : JSONValue])
    case JSONArray([JSONValue])
    case JSONBool(Bool)
    case JSONNull
    
    // This case is only supported for bridging NS* types because of the AnyObject requirement.
    // This should NOT be used externally.
    case _Invalid
    
    public init(_ value: Bool?) {
        if let bool = value {
            self = .JSONBool(bool)
        }
        else {
            self = .JSONNull
        }
    }
    
    public init(_ value: Double?) {
        if let number = value {
            self = .JSONNumber(number)
        }
        else {
            self = .JSONNull
        }
    }
    
    public init(_ value: Int?) {
        if let number = value {
            self = .JSONNumber(Double(number))
        }
        else {
            self = .JSONNull
        }
    }
    
    public init(_ value: String?) {
        if let string = value {
            self = .JSONString(string)
        }
        else {
            self = .JSONNull
        }
    }
    
    public init(_ value: [JSONValue]?) {
        if let array = value {
            self = .JSONArray(array)
        }
        else {
            self = .JSONNull
        }
    }
    
    public init(_ value: [String : JSONValue]?) {
        if let dict = value {
            self = .JSONObject(dict)
        }
        else {
            self = .JSONNull
        }
    }
    
    public init(_ bytes: [Byte], encoding: Encodings = Encodings.base64) {
        let data = NSData(bytes: bytes, length: bytes.count)
        
        switch encoding {
        case .base64:
            let encoded = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding76CharacterLineLength)
            self = .JSONString("\(encoding.toRaw())\(encoded)")
        }
    }
    
    public init(_ rawValue: AnyObject?) {
        if let value : AnyObject = rawValue {
            switch value {
            case let array as NSArray:
                var newArray = [JSONValue]()
                for item : AnyObject in array {
                    newArray += JSONValue(item)
                }
                self = .JSONArray(newArray)
                
            case let dict as NSDictionary:
                var newDict = [String : JSONValue]()
                for (k : AnyObject, v : AnyObject) in dict {
                    if let key = k as? String {
                        newDict[key] = JSONValue(v)
                    }
                    else {
                        assert(false, "Invalid key type; expected String")
                        self = ._Invalid
                        return
                    }
                }
                self = .JSONObject(newDict)
                
            case let string as NSString:
                self = .JSONString(string)
                
            case let number as NSNumber:
                if String.fromCString(number.objCType) == "c" {
                    self = .JSONBool(number.boolValue)
                }
                else {
                    self = .JSONNumber(number.doubleValue)
                }
                
            case let null as NSNull:
                self = .JSONNull
                
            default:
                assert(false, "This location should never be reached")
                self = ._Invalid
            }
        }
        else {
            self = .JSONNull
        }
    }

    /// Returns the `JSON` represented by the string or `nil` if the string is invalid JSON.
    public static func parse(jsonString : String) -> JSON? {
        var data = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var jsonObject : AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil)

        return jsonObject ? JSONValue(jsonObject) : nil
    }
    
     /// Create a pretty-printed representation of the `JSON`.
    public func stringify(indent: String = "  ") -> String? {
        switch self {
        case ._Invalid:
            assert(false, "The JSON value is invalid")
            return nil
            
        default:
            return prettyPrint(indent, 0)
        }
    }
    
    /// Retrieves the `String` representation of the value, or `nil`.
    public var string : String? {
        switch self {
        case .JSONString(let value):
            return value
            
        default:
            return nil
        }
    }
    
    /// Retrieves the `Double` representation of the value, or `nil`.
    public var number : Double? {
        switch self {
        case .JSONNumber(let value):
            return value
            
        default:
            return nil
        }
    }
    
    /// Retrieves the `Dictionary<String, JSONValue>` representation of the value, or `nil`.
    public var object : [String : JSONValue]? {
        switch self {
        case .JSONObject(let value):
            return value
            
        default:
            return nil
        }
    }
    
    /// Retrieves the `Array<JSONValue>` representation of the value, or `nil`.
    public var array : [JSONValue]? {
        switch self {
        case .JSONArray(let value):
            return value
            
        default:
            return nil
        }
    }
    
    /// Retrieves the `Bool` representation of the value, or `nil`.
    public var bool : Bool? {
        switch self {
        case .JSONBool(let value):
            return value
            
        default:
            return nil
        }
    }
    
    /// Returns the raw dencoded bytes of the value that was stored in the `string` value.
    public var decodedString: [Byte]? {
        switch self {
        case .JSONString(let encodedStringWithPrefix):
            if encodedStringWithPrefix.hasPrefix(Encodings.base64.toRaw()) {
                let encodedString = encodedStringWithPrefix.stringByReplacingOccurrencesOfString(Encodings.base64.toRaw(), withString: "")
                let decoded = NSData(base64EncodedString: encodedString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                
                let bytesPointer = UnsafePointer<Byte>(decoded.bytes)
                let bytes = UnsafeArray<Byte>(start: bytesPointer, length: decoded.length)
                return [Byte](bytes)
            }
            
        default:
            return nil
        }
            
        return nil
    }

    /// Attempts to treat the `JSONValue` as a dictionary and return the item with the given key.
    public subscript(key: String) -> JSONValue {
        switch self {
        case .JSONObject(let dict):
            if let result = dict[key] {
                return result
            } else {
                return JSONNull
            }
            
        default:
            return JSONNull
        }
    }

    /// Attempts to treat the `JSONValue` as an array and return the item at the index.
    public subscript(index: Int) -> JSONValue {
        switch self {
        case .JSONArray(let array):
            return array[index]
            
        default:
            return JSONNull
        }
    }
    
    /// Prints out the description of the JSON value as pretty-printed JSON.
    public var description: String {
        if let jsonString = stringify() {
            return jsonString
        }
        else {
            return "<INVALID JSON>"
        }
    }
}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch (lhs, rhs) {
    case (.JSONNull, .JSONNull):
        return true
        
    case (.JSONBool(let lhsValue), .JSONBool(let rhsValue)):
        return lhsValue == rhsValue

    case (.JSONString(let lhsValue), .JSONString(let rhsValue)):
        return lhsValue == rhsValue

    case (.JSONNumber(let lhsValue), .JSONNumber(let rhsValue)):
        return lhsValue == rhsValue

    case (.JSONArray(let lhsValue), .JSONArray(let rhsValue)):
        return lhsValue == rhsValue

    case (.JSONObject(let lhsValue), .JSONObject(let rhsValue)):
        return lhsValue == rhsValue
        
    default:
        return false
    }
}

extension JSON {
    func prettyPrint(indent: String, _ level: Int) -> String {
        let currentIndent = join(indent, map(0...level, { (item: Int) in "" }))
        let nextIndent = currentIndent + "  "
        
        switch self {
        case .JSONBool(let bool):
            return bool ? "true" : "false"
            
        case .JSONNumber(let number):
            return "\(number)"
            
        case .JSONString(let string):
            return "\"\(string)\""
            
        case .JSONArray(let array):
            return "[\n" + join(",\n", array.map({ "\(nextIndent)\($0.prettyPrint(indent, level + 1))" })) + "\n\(currentIndent)]"
            
        case .JSONObject(let dict):
            return "{\n" + join(",\n", map(dict, { "\(nextIndent)\"\($0)\" : \($1.prettyPrint(indent, level + 1))"})) + "\n\(currentIndent)}"
            
        case .JSONNull:
            return "null"
            
        case ._Invalid:
            assert(false, "This should never be reached")
            return ""
        }
    }
}

//
// MARK: Literal Convertibles to allow in-place boxing from literal values.
//

extension JSON : IntegerLiteralConvertible {
    public static func convertFromIntegerLiteral(value: Int) -> JSON {
        return .JSONNumber(Double(value))
    }
}

extension JSON : FloatLiteralConvertible {
    public static func convertFromFloatLiteral(value: Double) -> JSON {
        return .JSONNumber(value)
    }
}

extension JSON : StringLiteralConvertible {
    public static func convertFromStringLiteral(value: String) -> JSON {
        return .JSONString(value)
    }
    public static func convertFromExtendedGraphemeClusterLiteral(value: String) -> JSON {
        return .JSONString(value)
    }
}

extension JSON : ArrayLiteralConvertible {
    public static func convertFromArrayLiteral(elements: JSONValue...) -> JSON {
        return .JSONArray(elements)
    }
}

extension JSON : DictionaryLiteralConvertible {
    public static func convertFromDictionaryLiteral(elements: (String, JSONValue)...) -> JSON {
        var dict = [String : JSONValue]()
        for (k, v) in elements {
            dict[k] = v
        }
        
        return .JSONObject(dict)
    }
}

extension JSON : NilLiteralConvertible {
    public static func convertFromNilLiteral() -> JSON {
        return JSONNull
    }
}

extension JSON: BooleanLiteralConvertible {
    public static func convertFromBooleanLiteral(value: BooleanLiteralType) -> JSON {
        return JSONBool(value)
    }
}
