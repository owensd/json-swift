//
//  JSON.swift
//  JSON
//
//  Created by David Owens on 6/20/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

import Foundation

// Alias to make using a JSON structure for a single value more natural.
typealias JSONValue = JSON

// There is currently no BoolLiteralConvertible protocol to implement we need to hardcode this.
let JSTrue = JSONValue(true)
let JSFalse = JSONValue(false)

// Special handling for "null" as there seems to be no good way to do JSONValue(nil) for all types
let JSONNull = JSONValue.JSONNull

/**
 *  A representative type for all possible JSON values.
 *
 *  See http://json.org for a full description.
 */
enum JSON : Equatable, Printable {
    
    /**
     *  Provides a set of all of the valid encoding types when using data that needs to be stored
     *  within the contents of a string value.
     */
    enum Encodings : String {
        case base64 = "data:text/plain;base64,"
    }
    
    /*
     * All of the possible values representable by JSON.
     */
    
    case JSONString(Swift.String)
    case JSONNumber(Double)
    case JSONObject([String : JSONValue])
    case JSONArray([JSONValue])
    case JSONBool(Bool)
    case JSONNull
    
    // This case is only supported for bridging NS* types because of the AnyObject requirement.
    // This should NOT be used externally.
    case _Invalid
    
    init(_ value: Bool?) {
        if let bool = value {
            self = .JSONBool(bool)
        }
        else {
            self = .JSONNull
        }
    }
    
    init(_ value: Double?) {
        if let number = value {
            self = .JSONNumber(number)
        }
        else {
            self = .JSONNull
        }
    }
    
    init(_ value: Int?) {
        if let number = value {
            self = .JSONNumber(Double(number))
        }
        else {
            self = .JSONNull
        }
    }
    
    init(_ value: String?) {
        if let string = value {
            self = .JSONString(string)
        }
        else {
            self = .JSONNull
        }
    }
    
    init(_ value: Array<JSONValue>?) {
        if let array = value {
            self = .JSONArray(array)
        }
        else {
            self = .JSONNull
        }
    }
    
    init(_ value: Dictionary<String, JSONValue>?) {
        if let dict = value {
            self = .JSONObject(dict)
        }
        else {
            self = .JSONNull
        }
    }
    
    init(_ bytes: [Byte], encoding: Encodings = Encodings.base64) {
        let data = NSData(bytes: bytes, length: bytes.count)
        
        switch encoding {
        case .base64:
            let encoded = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding76CharacterLineLength)
            self = .JSONString("\(encoding.toRaw())\(encoded)")
        }
    }
    
    init(_ rawValue: AnyObject?) {
        if let value : AnyObject = rawValue {
            switch value {
            case let array as NSArray:
                var newArray = [JSONValue]()
                for item : AnyObject in array {
                    newArray += JSONValue(item)
                }
                self = .JSONArray(newArray)
                
            case let dict as NSDictionary:
                var newDict : Dictionary<String, JSONValue> = [:]
                for (k : AnyObject, v : AnyObject) in dict {
                    if let key = k as? String {
                        newDict[key] = JSONValue(v)
                    }
                    else {
                        assert(true, "Invalid key type; expected String")
                        self = ._Invalid
                        return
                    }
                }
                self = .JSONObject(newDict)
                
            case let string as NSString:
                self = .JSONString(string)
                
            case let number as NSNumber:
                if number.objCType == "c" {
                    self = .JSONBool(number.boolValue)
                }
                else {
                    self = .JSONNumber(number.doubleValue)
                }
                
            case let null as NSNull:
                self = .JSONNull
                
            default:
                assert(true, "This location should never be reached")
                self = ._Invalid
            }
        }
        else {
            self = .JSONNull
        }
    }

    /**
     * Returns the \c JSON represented by the string or \c nil if the string is invalid JSON.
     */
    static func parse(jsonString : String) -> JSON? {
        var data = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var jsonObject : AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil)

        return jsonObject ? JSONValue(jsonObject) : nil
    }
    
    /**
     * Create a pretty-printed representation of the \c JSON.
     */
    func stringify(indent: String = "  ") -> String? {
        switch self {
        case ._Invalid:
            assert(true, "The JSON value is invalid")
            return nil
            
        default:
            return _prettyPrint(indent, 0)
        }
    }
    
    /**
     * Retrieves the \c String representation of the value, or \c nil.
     */
    var string : String? {
        switch self {
        case .JSONString(let value):
            return value
            
        default:
            return nil
        }
    }
    
    /**
     * Retrieves the \c Double representation of the value, or \c nil.
     */
    var number : Double? {
        switch self {
        case .JSONNumber(let value):
            return value
            
        default:
            return nil
        }
    }
    
    /**
     * Retrieves the \c Dictionary<String, JSONValue> representation of the value, or \c nil.
     */
    var object : Dictionary<String, JSONValue>? {
        switch self {
        case .JSONObject(let value):
            return value
            
        default:
            return nil
        }
    }
    
    /**
     * Retrieves the \c Array<JSONValue> representation of the value, or \c nil.
     */
    var array : Array<JSONValue>? {
        switch self {
        case .JSONArray(let value):
            return value
            
        default:
            return nil
        }
    }
    
    /**
     * Retrieves the \c Bool representation of the value, or \c nil.
     */
    var bool : Bool? {
        switch self {
        case .JSONBool(let value):
            return value

        default:
            return nil
        }
    }
    
    /**
     * Returns the raw dencoded bytes of the value that was stored in the \c string value.
     */
    var decodedString: [Byte]? {
        switch self {
        case .JSONString(let encodedStringWithPrefix):
            if encodedStringWithPrefix.hasPrefix(Encodings.base64.toRaw()) {
                let encodedString = encodedStringWithPrefix.substringFromIndex(Encodings.base64.toRaw().lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
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

    /**
     * Attempts to treat the \c JSONValue as a dictionary and return the item with the given key.
     */
    subscript(key: String) -> JSONValue? {
        switch self {
        case .JSONObject(let dict):
            return dict[key]
            
        default:
            return nil
        }
    }

    /**
     * Attempts to treat the \c JSONValue as an array and return the item at the index.
     */
    subscript(index: Int) -> JSONValue? {
        switch self {
        case .JSONArray(let array):
            return array[index]
            
        default:
            return nil
        }
    }
    
    /**
     * Prints out the description of the JSON value as pretty-printed JSON.
     */
    var description: String {
        if let jsonString = stringify() {
            return jsonString
        }
        else {
            return "<INVALID JSON>"
        }
    }
}

func ==(lhs: JSON, rhs: JSON) -> Bool {
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


/*
 * Private APIs for JSON.
 */
extension JSON {
    func _prettyPrint(indent: String, _ level: Int) -> String {
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
            return "[\n" + join(",\n", array.map({ "\(nextIndent)\($0._prettyPrint(indent, level + 1))" })) + "\n\(currentIndent)]"
            
        case .JSONObject(let dict):
            return "{\n" + join(",\n", map(dict, { "\(nextIndent)\"\($0)\" : \($1._prettyPrint(indent, level + 1))"})) + "\n\(currentIndent)}"
            
        case .JSONNull:
            return "null"
            
        case ._Invalid:
            assert(true, "This should never be reached")
            return ""
        }
    }
}

//
// MARK: Literal Convertibles to allow in-place boxing from literal values.
//

extension JSON : IntegerLiteralConvertible {
    static func convertFromIntegerLiteral(value: Int) -> JSON {
        return .JSONNumber(Double(value))
    }
}

extension JSON : FloatLiteralConvertible {
    static func convertFromFloatLiteral(value: Double) -> JSON {
        return .JSONNumber(value)
    }
}

extension JSON : StringLiteralConvertible {
    static func convertFromStringLiteral(value: String) -> JSON {
        return .JSONString(value)
    }
    static func convertFromExtendedGraphemeClusterLiteral(value: String) -> JSON {
        return .JSONString(value)
    }
}

extension JSON : ArrayLiteralConvertible {
    static func convertFromArrayLiteral(elements: JSONValue...) -> JSON {
        return .JSONArray(elements)
    }
}

extension JSON : DictionaryLiteralConvertible {
    static func convertFromDictionaryLiteral(elements: (String, JSONValue)...) -> JSON {
        var dict = Dictionary<String, JSONValue>()
        for (k, v) in elements {
            dict[k] = v
        }
        
        return .JSONObject(dict)
    }
}

extension JSON : NilLiteralConvertible {
    static func convertFromNilLiteral() -> JSON {
        return JSONNull
    }
}
