//
//  JSValue.Path.swift
//  JSON
//
//  Created by Ranchao Zhang on 8/27/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

import Foundation

extension JSValue {
    public func get(path: String) -> JSValue {
        let components: [String] = path.componentsSeparatedByString(".")
        var value: JSValue = self;

        for component in components {
            if (value.hasValue) {
                value = value[component]
            } else {
                return value
            }
        }
    
        return value
    }

    public mutating func set(path: String, obj: JSValue) {
        self._set(path, obj: obj)
    }

    private mutating func _set(path: String, obj: JSValue) -> JSValue {
        let components: [String] = path.componentsSeparatedByString(".")
        var json: JSValue = self
    
        if self.hasValue {
            if let idx = path.rangeOfString(".")?.startIndex {
                let firstComponent = path.substringToIndex(idx)
                let subPath = path.substringFromIndex(idx.successor())
                
                json[firstComponent] = json[firstComponent]._set(subPath, obj: obj)
            } else {
                json[path] = obj
            }
            self = json
        }

        return self
    }
}