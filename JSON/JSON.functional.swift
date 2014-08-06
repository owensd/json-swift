//
//  JSON.functional.swift
//  JSON
//
//  Created by David Owens II on 8/4/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

import Foundation

/// Helper function that validates all of the error conditions leaving us with a `FailableOf<T>` with
/// either the value or error information set.
internal func failable<T>(value: JSValue?, key: String, fn: JSValue -> FailableOf<T>) -> FailableOf<T>
{
    if let dict = value {
        let item = dict[key]
        let failable = fn(item)
        if failable.failed {
            return FailableOf(failable.error!)
        }
        else {
            return FailableOf(failable.value!)
        }
    }
    else {
        return FailableOf(Error(
            code: JSValue.ErrorCodes.NullValue.toRaw(),
            domain: JSValueErrorDomain,
            userInfo: [LocalizedDescriptionKey: "The specified value is nil."]))
    }
}

/// Helper function that validates all of the error conditions leaving us with a `FailableOf<T>` with
/// either the value or error information set.
internal func failable<T>(value: JSValue?, index: Int, fn: JSValue -> FailableOf<T>) -> FailableOf<T>
{
    if let array = value {
        let item = array[index]
        let failable = fn(item)
        if failable.failed {
            return FailableOf(failable.error!)
        }
        else {
            return FailableOf(failable.value!)
        }
    }
    else {
        return FailableOf(Error(
            code: JSValue.ErrorCodes.NullValue.toRaw(),
            domain: JSValueErrorDomain,
            userInfo: [LocalizedDescriptionKey: "The specified value is nil."]))
    }
}

/// Retrieves a `FailableOf<String>` from `value` with the given `key`.
///
/// :param: value The dictionary holding the value to retrieve.
/// :param: key The key to retrieve the value with.
/// :returns: Either the value wrapped in `FailableOf<T>` or an `Error` in `FailableOf<T>`.
public func string(value: FailableOf<JSValue>, key: String) -> FailableOf<String>
{
    if let error = value.error {
        return FailableOf(error)
    }
    else {
        return failable(value.value, key) { item in item.string }
    }
}

/// Retrieves a `FailableOf<String>` from `value` with the given `index`.
///
/// :param: value The array holding the value to retrieve.
/// :param: index The index to retrieve the value with.
/// :returns: Either the value wrapped in `FailableOf<T>` or an `Error` in `FailableOf<T>`.
public func string(value: FailableOf<JSValue>, index: Int) -> FailableOf<String>
{
    if let error = value.error {
        return FailableOf(error)
    }
    else {
        return failable(value.value, index) { item in item.string }
    }
}

/// Retrieves a `FailableOf<String>` from `value` with the given `key`.
///
/// :param: value The dictionary holding the value to retrieve.
/// :param: key The key to retrieve the value with.
/// :returns: Either the value wrapped in `FailableOf<T>` or an `Error` in `FailableOf<T>`.
public func string(value: JSValue?, key: String) -> FailableOf<String>
{
    return failable(value, key) { item in item.string }
}

/// Retrieves a `FailableOf<String>` from `value` with the given `index`.
///
/// :param: value The array holding the value to retrieve.
/// :param: index The index to retrieve the value with.
/// :returns: Either the value wrapped in `FailableOf<T>` or an `Error` in `FailableOf<T>`.
public func string(value: JSValue?, index: Int) -> FailableOf<String>
{
    return failable(value, index) { item in item.string }
}

/// Retrieves a `FailableOf<Double>` from `value` with the given `key`.
///
/// :param: value The dictionary holding the value to retrieve.
/// :param: key The key to retrieve the value with.
/// :returns: Either the value wrapped in `FailableOf<T>` or an `Error` in `FailableOf<T>`.
public func number(value: FailableOf<JSValue>, key: String) -> FailableOf<Double>
{
    if let error = value.error {
        return FailableOf(error)
    }
    else {
        return failable(value.value, key) { item in item.number }
    }
}

/// Retrieves a `FailableOf<Double>` from `value` with the given `index`.
///
/// :param: value The array holding the value to retrieve.
/// :param: index The index to retrieve the value with.
/// :returns: Either the value wrapped in `FailableOf<T>` or an `Error` in `FailableOf<T>`.
public func number(value: FailableOf<JSValue>, index: Int) -> FailableOf<Double>
{
    if let error = value.error {
        return FailableOf(error)
    }
    else {
        return failable(value.value, index) { item in item.number }
    }
}

/// Retrieves a `FailableOf<Double>` from `value` with the given `key`.
///
/// :param: value The dictionary holding the value to retrieve.
/// :param: key The key to retrieve the value with.
/// :returns: Either the value wrapped in `FailableOf<T>` or an `Error` in `FailableOf<T>`.
public func number(value: JSValue?, key: String) -> FailableOf<Double>
{
    return failable(value, key) { item in item.number }
}

/// Retrieves a `FailableOf<Double>` from `value` with the given `index`.
///
/// :param: value The array holding the value to retrieve.
/// :param: index The index to retrieve the value with.
/// :returns: Either the value wrapped in `FailableOf<T>` or an `Error` in `FailableOf<T>`.
public func number(value: JSValue?, index: Int) -> FailableOf<Double>
{
    return failable(value, index) { item in item.number }
}

/// Retrieves a `FailableOf<Bool>` from `value` with the given `key`.
///
/// :param: value The dictionary holding the value to retrieve.
/// :param: key The key to retrieve the value with.
/// :returns: Either the value wrapped in `FailableOf<T>` or an `Error` in `FailableOf<T>`.
public func bool(value: FailableOf<JSValue>, key: String) -> FailableOf<Bool>
{
    if let error = value.error {
        return FailableOf(error)
    }
    else {
        return failable(value.value, key) { item in item.bool }
    }
}

/// Retrieves a `FailableOf<Bool>` from `value` with the given `index`.
///
/// :param: value The array holding the value to retrieve.
/// :param: index The index to retrieve the value with.
/// :returns: Either the value wrapped in `FailableOf<T>` or an `Error` in `FailableOf<T>`.
public func bool(value: FailableOf<JSValue>, index: Int) -> FailableOf<Bool>
{
    if let error = value.error {
        return FailableOf(error)
    }
    else {
        return failable(value.value, index) { item in item.bool }
    }
}

/// Retrieves a `FailableOf<Bool>` from `value` with the given `key`.
///
/// :param: value The dictionary holding the value to retrieve.
/// :param: key The key to retrieve the value with.
/// :returns: Either the value wrapped in `FailableOf<T>` or an `Error` in `FailableOf<T>`.
public func bool(value: JSValue?, key: String) -> FailableOf<Bool>
{
    return failable(value, key) { item in item.bool }
}

/// Retrieves a `FailableOf<Bool>` from `value` with the given `index`.
///
/// :param: value The array holding the value to retrieve.
/// :param: index The index to retrieve the value with.
/// :returns: Either the value wrapped in `FailableOf<T>` or an `Error` in `FailableOf<T>`.
public func bool(value: JSValue?, index: Int) -> FailableOf<Bool>
{
    return failable(value, index) { item in item.bool }
}

