//
//  JSValue.Parsing.NSDictionary.swift
//  JSON
//
//  Created by Ranchao Zhang on 8/27/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

extension JSValue {
    class func parse(dictionary: NSDictionary) -> JSValue {
        let backingValue = JSBackingValue.JSObject(dictionary)
        return JSValue(backingValue)
    }
}