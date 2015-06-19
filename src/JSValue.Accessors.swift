//
//  JSON.accessors.swift
//  JSON
//
//  Created by David Owens II on 8/11/14.
//  Copyright (c) 2014 David Owens II. All rights reserved.
//

/*
 * Provides extensions to the `JSValue` class that allows retrieval of the supported `JSValue.JSBackingValue` values.
 */

extension JSValue {
    
    /// Attempts to retrieve a `String` out of the `JSValue`.
    ///
    /// - returns: If the `JSValue` is a `JSString`, then the stored `String` value is returned, otherwise `nil`.
    public var string: String? {
        switch self.value {
        case .JSString(let value): return value
        default: return nil
        }
    }

    /// Attempts to retrieve a `Double` out of the `JSValue`.
    ///
    /// - returns: If the `JSValue` is a `JSNumber`, then the stored `Double` value is returned, otherwise `nil`.
    public var number: Double? {
        switch self.value {
        case .JSNumber(let value): return value
        default: return nil
        }
    }
    
    /// Attempts to retrieve a `Bool` out of the `JSValue`.
    ///
    /// - returns: If the `JSValue` is a `JSBool`, then the stored `Double` value is returned, otherwise `nil`.
    public var bool: Bool? {
        switch self.value {
        case .JSBool(let value): return value
        default: return nil
        }
    }

    /// Attempts to retrieve a `[String:JSValue]` out of the `JSValue`.
    ///
    /// - returns: If the `JSValue` is a `JSObject`, then the stored `[String:JSValue]` value is returned, otherwise `nil`.
    public var object: [String:JSValue]? {
        switch self.value {
        case .JSObject(let value): return value
        default: return nil
        }
    }
    
    /// Attempts to retrieve a `[JSValue]` out of the `JSValue`.
    ///
    /// - returns: If the `JSValue` is a `JSArray`, then the stored `[JSValue]` value is returned, otherwise `nil`.
    public var array: [JSValue]? {
        switch self.value {
        case .JSArray(let value): return value
        default: return nil
        }
    }
    
    /// Used to determine if a `nil` value is stored within `JSValue`. There is no intrinsic type for this value.
    ///
    /// - returns: If the `JSValue` is a `JSNull`, then the `true` is returned, otherwise `false`.
    public var null: Bool {
        switch self.value {
        case .JSNull: return true
        default: return false
        }
    }
    
    /// Determines if the `JSValue` has a value stored within it.
    ///
    /// - returns: `true` if the `JSValue` has a valid value stored, `false` if the `JSValue` is `Invalid`.
    public var hasValue: Bool {
        switch self.value {
        case .Invalid(_): return false
        default: return true
        }
    }
    
    /// The error information that is held when `hasValue` is `false`.
    public var error: Error? {
        switch self.value {
        case .Invalid(let error): return error
        default: return nil
        }
    }
}
