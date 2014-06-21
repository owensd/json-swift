//
//  JSON.swift
//  JSON
//
//  Created by David Owens on 6/20/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

import Foundation

typealias JSValue = JSON

// There is currently no BoolLiteralConvertible protocol to implement we need to hardcode this.
let JSTrue = JSValue(true)
let JSFalse = JSValue(false)

// Special handling for "null" as there seems to be no good way to do JSValue(nil) for all types
let JSNull = JSValue.JSNull

/**
 *  A representative type for all possible JSON values.
 *
 *  See http://json.org for a full description.
 */
enum JSON : LogicValue {
    
    /*
     * All of the possible values representable by JSON.
     */
    
    case JSString(String)
    case JSNumber(Double)
    case JSObject(Dictionary<String, JSValue>)
    case JSArray(JSValue[])
    case JSBool(Bool)
    case JSNull
    
    /*
     * Respresents a valid that is not reprentable in JSON.
     */
    case InvalidValue
    
    func getLogicValue() -> Bool {
        switch self {
        case .JSBool(let bool):
            return bool
            
        default:
            return false
        }
    }

    init(_ value: Bool?) {
        if let bool = value {
            self = .JSBool(bool)
        }
        else {
            self = .JSNull
        }
    }
    
    init(_ value: Double?) {
        if let number = value {
            self = .JSNumber(number)
        }
        else {
            self = .JSNull
        }
    }
    
    init(_ value: Int?) {
        if let number = value {
            self = .JSNumber(Double(number))
        }
        else {
            self = .JSNull
        }
    }
    
    init(_ value: String?) {
        if let string = value {
            self = .JSString(string)
        }
        else {
            self = .JSNull
        }
    }
    
    init(_ value: Array<JSValue>?) {
        if let array = value {
            self = .JSArray(array)
        }
        else {
            self = .JSNull
        }
    }
    
    init(_ value: Dictionary<String, JSValue>?) {
        if let dict = value {
            self = .JSObject(dict)
        }
        else {
            self = .JSNull
        }
    }
    
    init(_ rawValue: AnyObject?) {
        if let value : AnyObject = rawValue {
            switch value {
            case let array as NSArray:
                var newArray : JSValue[] = []
                for item : AnyObject in array {
                    newArray += JSValue(item)
                }
                self = .JSArray(newArray)
                
            case let dict as NSDictionary:
                var newDict : Dictionary<String, JSValue> = [:]
                for (k : AnyObject, v : AnyObject) in dict {
                    if let key = k as? String {
                        newDict[key] = JSValue(v)
                    }
                    else {
                        self = .InvalidValue
                        break;
                    }
                }
                self = .JSObject(newDict)
                
            case let string as NSString:
                self = .JSString(string)
                
            case let number as NSNumber:
                println(number.objCType)
                if number.objCType == "c" {
                    self = .JSBool(number.boolValue)
                }
                else {
                    self = .JSNumber(number.doubleValue)
                }
                
            case let null as NSNull:
                self = .JSNull
                
            default:
                self = .InvalidValue
            }
        }
        else {
            self = .InvalidValue
        }
    }
    
    static func parse(jsonString : String) -> JSON? {
        var data = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var jsonObject : AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil)
        
        return jsonObject == nil ? nil : JSValue(jsonObject)
    }
    
    func stringify() -> String? {
        //
        // NOTE: Using NSJSONSerialization method currently fails with a bad access on the types...
        // I think it has to do the with the types in the array and issues with bridging Dictionary<> and NSDictionary.
        //
        //var data : NSData? = nil
        //switch self {
        //case .JSArray(let array):
        //    data = NSJSONSerialization.dataWithJSONObject(array, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        //    
        //case .JSObject(let dict):
        //    data = NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        //    
        //default:
        //    data = nil
        //}
        //
        //return data == nil ? nil : NSString(data: data, encoding: NSUTF8StringEncoding)
        
        switch self {
        case .InvalidValue:
            return nil
            
        default:
            return _prettyPrint(0)
        }
    }
    
    func _prettyPrint(level: Int) -> String {
        let indent = join("  ", map(0...level, { (item: Int) in "" }))
        let nextIndent = indent + "  "
        
        switch self {
        case .JSBool(let bool):
            return bool ? "true" : "false"
            
        case .JSNumber(let number):
            return "\(number)"
            
        case .JSString(let string):
            return "\"\(string)\""
            
        case .JSArray(let array):
            return "[\n" + join(",\n", array.map({ "\(nextIndent)\($0._prettyPrint(level + 1))" })) + "\n\(indent)]"
            
        case .JSObject(let dict):
            return "{\n" + join(",\n", map(dict, { "\(nextIndent)\"\($0)\" : \($1._prettyPrint(level + 1))"})) + "\n\(indent)}"
            
        default:
            return ""
        }
    }
    
    var string : String? {
        switch self {
        case .JSString(let value):
            return value
            
        default:
            return nil
        }
    }
    
    var number : Double? {
        switch self {
        case .JSNumber(let value):
            return value
            
        default:
            return nil
        }
    }
    
    var object : Dictionary<String, JSValue>? {
        switch self {
        case .JSObject(let value):
            return value
            
        default:
            return nil
        }
    }
    
    var array : Array<JSValue>? {
        switch self {
        case .JSArray(let value):
            return value
            
        default:
            return nil
        }
    }
    
    var bool : Bool? {
        switch self {
        case .JSBool(let value):
            return value

        default:
            return nil
        }
    }

    subscript(key: String) -> JSValue? {
        switch self {
        case .JSObject(let dict):
            return dict[key]
            
        default:
            return nil
        }
    }

    subscript(index: Int) -> JSValue? {
        switch self {
        case .JSArray(let array):
            return array[index]
            
        default:
            return nil
        }
    }
}

extension JSON : IntegerLiteralConvertible {
    static func convertFromIntegerLiteral(value: Int) -> JSON {
        return .JSNumber(Double(value))
    }
}

extension JSON : FloatLiteralConvertible {
    static func convertFromFloatLiteral(value: Double) -> JSON {
        return .JSNumber(value)
    }
}

extension JSON : StringLiteralConvertible {
    static func convertFromStringLiteral(value: String) -> JSON {
        return .JSString(value)
    }
    static func convertFromExtendedGraphemeClusterLiteral(value: String) -> JSON {
        return .JSString(value)
    }
}

extension JSON : ArrayLiteralConvertible {
    static func convertFromArrayLiteral(elements: JSValue...) -> JSON {
        return .JSArray(elements)
    }
}

extension JSON : DictionaryLiteralConvertible {
    static func convertFromDictionaryLiteral(elements: (String, JSValue)...) -> JSON {
        var dict = Dictionary<String, JSValue>()
        for (k, v) in elements {
            dict[k] = v
        }
        
        return .JSObject(dict)
    }
}
