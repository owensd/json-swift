//
//  JSON.indexers.swift
//  JSON
//
//  Created by David Owens II on 8/11/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

extension JSValue {
    
    /// Attempts to treat the `JSValue` as a `JSObject` and perform the lookup.
    ///
    /// :returns: A `JSValue` that represents the value found at `key`
    public subscript(key: String) -> JSValue {
        get {
            if let dict = self.object {
                if let value = dict[key] {
                    return value
                }
                
                let error = Error(
                    code: JSValue.ErrorCode.KeyNotFound.code,
                    domain: JSValueErrorDomain,
                    userInfo: [ErrorKeys.LocalizedDescription: JSValue.ErrorCode.KeyNotFound.message])
                return JSValue(error)
            } else if let array = self.array {
                let idx: Int? = key.toInt()
                if idx != nil && idx >= 0 && array.count > idx! {
                    return array[idx!]
                }
    
                 let error = Error(
                    code: JSValue.ErrorCode.KeyNotFound.code,
                    domain: JSValueErrorDomain,
                    userInfo: [ErrorKeys.LocalizedDescription: JSValue.ErrorCode.KeyNotFound.message])
                return JSValue(error)
            }

            let error = Error(
                code: JSValue.ErrorCode.IndexingIntoUnsupportedType.code,
                domain: JSValueErrorDomain,
                userInfo: [ErrorKeys.LocalizedDescription: JSValue.ErrorCode.IndexingIntoUnsupportedType.message])
            return JSValue(error)
        }
        set {
            if var dict = self.object {
                dict[key] = newValue
                self = JSValue(dict)
            } else if var array = self.array {
                let idx: Int? = key.toInt()
                if idx != nil && idx >= 0 && array.count > idx! {
                    array[idx!] = newValue
                    self = JSValue(array)
                }
            }
        }
    }
    
    /// Attempts to treat the `JSValue` as an array and return the item at the index.
    public subscript(index: Int) -> JSValue {
        get {
            if let array = self.array {
                if index >= 0 && index < array.count {
                    return array[index]
                }
                
                let error = Error(
                    code: JSValue.ErrorCode.IndexOutOfRange.code,
                    domain: JSValueErrorDomain,
                    userInfo: [ErrorKeys.LocalizedDescription: JSValue.ErrorCode.IndexOutOfRange.message])
                return JSValue(error)
            }
            
            let error = Error(
                code: JSValue.ErrorCode.IndexingIntoUnsupportedType.code,
                domain: JSValueErrorDomain,
                userInfo: [ErrorKeys.LocalizedDescription: JSValue.ErrorCode.IndexingIntoUnsupportedType.message])
            return JSValue(error)
        }
        set {
            if var array = self.array {
                array[index] = newValue
                self = JSValue(array)
            }
        }
    }
}
