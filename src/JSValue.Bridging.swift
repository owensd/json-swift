//
//  JSON.bridging.swift
//  JSON
//
//  Created by David Owens II on 8/8/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

import Foundation

extension JSValue {
//    /// Initializes a new `JSValue` with a `[Byte]`.
//    public init(_ bytes: [Byte], encoding: Encodings = Encodings.base64) {
//        let data = NSData(bytes: bytes, length: bytes.count)
//        self.init(data, encoding: encoding)
//    }
//    
//    /// Initializes a new `JSValue` with a `[Byte]`.
//    public init(_ data: NSData, encoding: Encodings = Encodings.base64) {
//        switch encoding {
//        case .base64:
//            let encoded = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding76CharacterLineLength)
//            self = .JSString("\(encoding.toRaw())\(encoded)")
//        }
//    }
//    
//    /// Initializes a new `JSValue` from an `AnyObject?`. If a failure occurs, the `JSValue` will be `Invalid`.
//    public init(_ rawValue: AnyObject?) {
//        if let value : AnyObject = rawValue {
//            switch value {
//            case let array as NSArray:
//                var newArray = [JSValue]()
//                for item : AnyObject in array {
//                    newArray += [JSValue(item)]
//                }
//                self = .JSArray(newArray)
//                
//            case let dict as NSDictionary:
//                var newDict = [String : JSValue]()
//                for (k : AnyObject, v : AnyObject) in dict {
//                    if let key = k as? String {
//                        newDict[key] = JSValue(v)
//                    }
//                    else {
//                        let info = [LocalizedDescriptionKey: "Invalid key type; expected String"]
//                        let error = Error(code: JSValue.ErrorCodes.InvalidKeyType.toRaw(), domain: JSValueErrorDomain, userInfo: info)
//                        self = .Invalid(error)
//                        return
//                    }
//                }
//                self = .JSObject(newDict)
//                
//            case let string as NSString:
//                self = .JSString(string)
//                
//            case let number as NSNumber:
//                if String.fromCString(number.objCType) == "c" {
//                    self = .JSBool(number.boolValue)
//                }
//                else {
//                    self = .JSNumber(number.doubleValue)
//                }
//                
//            case let null as NSNull:
//                self = .JSNull
//                
//            default:
//                let info = [LocalizedDescriptionKey: "Unsupported JSON type attempting to be serialized."]
//                let error = Error(code: JSValue.ErrorCodes.UnsupportedType.toRaw(), domain: JSValueErrorDomain, userInfo: info)
//                self = .Invalid(error)
//            }
//        }
//        else {
//            self = .JSNull
//        }
//    }
}