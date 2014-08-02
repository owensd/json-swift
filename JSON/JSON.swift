//
//  JSON.swift
//  JSON
//
//  Created by David Owens on 6/20/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

import Foundation

// Alias to make using a JSON structure for a single value more natural.
public typealias JSON = JSONValue

/// A representative type for all possible JSON values.
///
/// See http://json.org for a full description.
public enum JSONValue : Equatable, Printable {
    
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
    case JSONError(NSError)
    
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
            
        default:
            let info = [NSLocalizedDescriptionKey: "JSON parser error: Unknown encoding"]
            self = .JSONError(NSError(domain: "JSONErrorDomain", code: 1000, userInfo: info))
        }
    }
    
    public init(_ rawValue: AnyObject?) {
        if let value: AnyObject = rawValue {
            switch value {
            case let array as NSArray:
                var newArray = [JSONValue]()
                for item: AnyObject in array {
                    newArray += JSONValue(item)
                }
                self = .JSONArray(newArray)
                
            case let dict as NSDictionary:
                var newDict = [String: JSONValue]()
                for (k: AnyObject, v: AnyObject) in dict {
                    if let key = k as? String {
                        newDict[key] = JSONValue(v)
                    } else {
                        let info = [NSLocalizedDescriptionKey: "JSON parser error: Invalid key type; expected String"]
                        self = .JSONError(NSError(domain: "JSONErrorDomain", code: 1000, userInfo: info))
                        return
                    }
                }
                self = .JSONObject(newDict)
                
            case let string as NSString:
                self = .JSONString(string)
                
            case let number as NSNumber:
                if String.fromCString(number.objCType) == "c" {
                    self = .JSONBool(number.boolValue)
                } else {
                    self = .JSONNumber(number.doubleValue)
                }
                
            case let null as NSNull:
                self = .JSONNull
                
            default:
                let info = [NSLocalizedDescriptionKey: "JSON parser error: Given object is not a JSON value"]
                self = .JSONError(NSError(domain: "JSONErrorDomain", code: 1000, userInfo: info))
            }
        } else {
            let info = [NSLocalizedDescriptionKey: "JSON parser error: Trying to implicitly create a JSON null"]
            self = .JSONError(NSError(domain: "JSONErrorDomain", code: 1000, userInfo: info))
        }
    }
    
    public init(_ rawData: NSData?) {
        if let data = rawData {
            var error: NSError?
            if let jsonObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) {
                self = JSONValue(jsonObject)
            } else if let error = error {
                self = .JSONError(error)
            } else {
                let info = [NSLocalizedDescriptionKey:"JSON parser error: Invalid JSON data"]
                self = .JSONError(NSError(domain: "JSONErrorDomain", code: 1000, userInfo: info))
            }
        } else {
            let info = [NSLocalizedDescriptionKey:"JSON parser error: Creating JSONValue with nil NSData"]
            self = .JSONError(NSError(domain: "JSONErrorDomain", code: 1000, userInfo: info))
        }
        
    }

    /// Returns the `JSON` represented by the string or `nil` if the string is invalid JSON.
    public static func parse(jsonString : String) -> JSON? {
        var data = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var jsonObject : AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil)

        return jsonObject ? JSONValue(jsonObject) : nil
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
    
    /// Retrieves the `Int` representation of the value, or `nil`.
    public var integer : Int? {
        switch self {
        case .JSONNumber(let value):
            return Int(value)
            
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
    
    /// Retrieves the `NSError` representation of the value, or `nil`.
    public var error : NSError? {
        switch self {
        case .JSONError(let value):
            return value
            
        default:
            return nil
        }
    }
    
    /// Returns true if the `JSONValue` contains a meaningful JSON value, false if an error occurred.
    public var hasValue : Bool {
        switch self {
        case .JSONError:
            return false
            
        default:
            return true
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
        get {
            switch self {
            case .JSONObject(let dict):
                if let result = dict[key] {
                    return result
                } else {
                    let info = [NSLocalizedDescriptionKey: "JSON path error: Incorrect path \"\(key)\"", "JSONErrorPath": key]
                    return .JSONError(NSError(domain: "JSONErrorDomain", code: 1001, userInfo: info))
                }
            
            case .JSONError(let error):
                if let oldInfo = error.userInfo {
                    if let oldPath = oldInfo["JSONErrorPath"] as? NSString {
                        let info = [NSLocalizedDescriptionKey: "JSON path error: Incorrect path \"\(oldPath)/\(key)\"",
                            "JSONErrorPath": "\(oldPath)/\(key)"]
                        return .JSONError(NSError(domain: "JSONErrorDomain", code: 1001, userInfo: info))
                    }
                }
                return self
                
            default:
                let info = [NSLocalizedDescriptionKey: "JSON path error: Incorrect path \"\(key)\"", "JSONErrorPath": key]
                return .JSONError(NSError(domain: "JSONErrorDomain", code: 1001, userInfo: info))
            }
        }
        set {
            if let dict = self.object {
                var copy = dict
                copy[key] = newValue
                self = .JSONObject(copy)
            }
        }
    }

    /// Attempts to treat the `JSONValue` as an array and return the item at the index.
    public subscript(index: Int) -> JSONValue {
        get {
            switch self {
            case .JSONArray(let array):
                if index >= 0 && index < array.count {
                    return array[index]
                } else {
                    let info = [NSLocalizedDescriptionKey: "JSON path error: Incorrect path \"\(index)\"", "JSONErrorPath": index]
                    return .JSONError(NSError(domain: "JSONErrorDomain", code: 1001, userInfo: info))
                }
                
            case .JSONError(let error):
                if let oldInfo = error.userInfo {
                    if let oldPath = oldInfo["JSONErrorPath"] as? NSString {
                        let info = [NSLocalizedDescriptionKey: "JSON path error: Incorrect path \"\(oldPath)/\(index)\"",
                            "JSONErrorPath": "\(oldPath)/\(index)"]
                        return .JSONError(NSError(domain: "JSONErrorDomain", code: 1001, userInfo: info))
                    }
                }
                return self
                
            default:
                let info = [NSLocalizedDescriptionKey: "JSON path error: Incorrect path \"\(index)\"", "JSONErrorPath": index]
                return .JSONError(NSError(domain: "JSONErrorDomain", code: 1001, userInfo: info))
            }
        }
        set {
            if let array = self.array {
                var copy = array
                copy[index] = newValue
                self = .JSONArray(copy)
            }
        }
    }
    
    private func prettyPrint(indent: String = "  ", level: Int = 0, baseIndent: String? = nil) -> String {
        var currentIndent: String
        if let baseIndent = baseIndent {
            currentIndent = baseIndent
        } else {
            currentIndent = join("", [String](count: level, repeatedValue: indent))
        }
        let nextIndent = currentIndent + indent
        
        switch self {
        case .JSONBool(let bool):
            return bool ? "true" : "false"
            
        case .JSONNumber(let number):
            return "\(number)"
            
        case .JSONString(let string):
            return "\"\(string)\""
            
        case .JSONArray(let array):
            let children = array.map { item -> String in
                let child = item.prettyPrint(indent: indent, level: level + 1, baseIndent: nextIndent)
                return "\(nextIndent)\(child)"
            }
            return "[\n" + join(",\n", children) + "\n\(currentIndent)]"
            
        case .JSONObject(let dict):
            let children = map(dict) { key, value -> String in
                let child = value.prettyPrint(indent: indent, level: level + 1, baseIndent: nextIndent)
                return "\(nextIndent)\"\(key)\" : \(child)"
            }
            return "{\n" + join(",\n", children) + "\n\(currentIndent)}"
            
        case .JSONNull:
            return "null"
            
        case .JSONError(let error):
            return error.localizedDescription
        }
    }
    
    /// Create a pretty-printed representation of the `JSONValue`.
    public func stringify(indent: String = "  ", level: Int = 0, baseIndent: String? = nil) -> String {
        return prettyPrint(indent: indent, level: level, baseIndent: baseIndent)
    }
    
    /// Create a pretty-printed representation of the `JSONValue`.
    public var description: String {
        return prettyPrint()
    }
}

public func ==(lhs: JSONValue, rhs: JSONValue) -> Bool {
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

//
// MARK: Literal Convertibles to allow in-place boxing from literal values.
//

extension JSONValue: IntegerLiteralConvertible {
    public static func convertFromIntegerLiteral(value: Int) -> JSONValue {
        return .JSONNumber(Double(value))
    }
}

extension JSONValue: FloatLiteralConvertible {
    public static func convertFromFloatLiteral(value: Double) -> JSONValue {
        return .JSONNumber(value)
    }
}

extension JSONValue: StringLiteralConvertible {
    public static func convertFromStringLiteral(value: String) -> JSONValue {
        return .JSONString(value)
    }
    public static func convertFromExtendedGraphemeClusterLiteral(value: String) -> JSONValue {
        return .JSONString(value)
    }
}

extension JSONValue: ArrayLiteralConvertible {
    public static func convertFromArrayLiteral(elements: JSONValue...) -> JSONValue {
        return .JSONArray(elements)
    }
}

extension JSONValue: DictionaryLiteralConvertible {
    public static func convertFromDictionaryLiteral(elements: (String, JSONValue)...) -> JSONValue {
        var dict = [String : JSONValue]()
        for (k, v) in elements {
            dict[k] = v
        }
        
        return .JSONObject(dict)
    }
}

extension JSONValue: NilLiteralConvertible {
    public static func convertFromNilLiteral() -> JSONValue {
        return .JSONNull
    }
}

extension JSONValue: BooleanLiteralConvertible {
    public static func convertFromBooleanLiteral(value: BooleanLiteralType) -> JSONValue {
        return JSONBool(value)
    }
}