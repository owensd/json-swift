//
//  JSValue.Parsing.swift
//  JSON
//
//  Created by David Owens II on 8/12/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

extension JSValue {
    /// Parses the given string and attempts to return a `JSValue` from it.
    ///
    /// :param: string the string that contains the JSON to parse.
    ///
    /// :returns: A `FailableOf<T>` that will contain the parsed `JSValue` if successful,
    ///           otherwise, the `Error` information for the parsing.
    public static func parse(string : String) -> FailableOf<JSValue> {
        var index = string.startIndex
        let value = parse(string, startAt: &index)
        
        for ; index < string.endIndex; index = index.successor() {
            if !whitespace(string[index]) {
                
                let info = [
                    ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                    ErrorKeys.LocalizedFailureReason: "Invalid characters after the last item in the JSON: \(string[index]) @ \(index)"]
                return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
            }
        }
        
        return value
    }
    
    /// Parses the given string and attempts to return a `JSValue` from it.
    ///
    /// :param: string the string that contains the JSON to parse.
    /// :param: startAt the index to start parsing the string from.
    ///
    /// :returns: A `FailableOf<T>` that will contain the parsed `JSValue` if successful,
    ///           otherwise, the `Error` information for the parsing.
    static func parse(string: String, inout startAt index: String.Index) -> FailableOf<JSValue> {
        
        for ; index < string.endIndex; index = index.successor() {
            let c = string[index]
            
            if whitespace(c) { continue; }
            
            if c == "{" {
                return parseObject(string, startAt: &index)
            }
            else if c == "[" {
                return parseArray(string, startAt: &index)
            }
            else if digit(c) != nil || c == "-" {
                return parseNumber(string, startAt: &index)
            }
            else if c == "t" {
                return parseTrue(string, startAt: &index)
            }
            else if c == "f" {
                return parseFalse(string, startAt: &index)
            }
            else if c == "n" {
                return parseNull(string, startAt: &index)
            }
            else if c == "\"" || c == "'" {
                return parseString(string, startAt: &index, quoteChar: c)
            }
        }
        
        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "No valid JSON value was found to parse in string."]
        return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
    }

    static func whitespace(char: Character) -> Bool {
        if char == " "      { return true }
        if char == "\t"     { return true }
        if char == "\r"     { return true }
        if char == "\n"     { return true }
        if char == "\r\n"   { return true }
        
        return false
    }
    
    static func digit(char: Character) -> Int? {
        if char == "0" { return 0 }
        if char == "1" { return 1 }
        if char == "2" { return 2 }
        if char == "3" { return 3 }
        if char == "4" { return 4 }
        if char == "5" { return 5 }
        if char == "6" { return 6 }
        if char == "7" { return 7 }
        if char == "8" { return 8 }
        if char == "9" { return 9 }
        
        return nil
    }
    
    static func parseObject(string: String, inout startAt index: String.Index) -> FailableOf<JSValue> {
        
        enum State {
            case Initial
            case Key
            case Value
        }
        
        index = index.successor()
        
        var state = State.Initial

        var key = ""
        var jsvalue = [String:JSValue]()
        for ; index < string.endIndex; index = index.successor() {
            let c = string[index]
            
            if whitespace(c) { /* do nothing */ }
            else if c == "}" {
                switch state {
                case .Initial: fallthrough
                case .Value:
                    index = index.successor()
                    return FailableOf(JSValue(JSBackingValue.JSObject(jsvalue)))
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "The '}' was unexpected at this point."]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }
            }
            else if c == "'" || c == "\"" {
                switch state {
                case .Initial:
                    state = .Key
                    
                    let parsedKey = parseString(string, startAt: &index, quoteChar: c)
                    if let error = parsedKey.error {
                        return FailableOf(error)
                    }
                    
                    if let parsedKey = parsedKey.value?.string {
                        key = parsedKey
                    }
                    
                    index = index.predecessor()
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(c) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }
            }
            else if c == ":" {
                switch state {
                case .Key:
                    state = .Value
                    
                    let parsedValue = parse(string, startAt: &index)
                    if parsedValue.failed {
                        return parsedValue
                    }
                    else if let value = parsedValue.value {
                        jsvalue[key] = value
                    }
                    
                    index = index.predecessor()
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(c) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }
            }
            else if c == "," {
                switch state {
                case .Value:
                    state = .Initial
                    key = ""
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(c) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }
            }
            else {
                let info = [
                    ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                    ErrorKeys.LocalizedFailureReason: "Unexpected token: \(c) @ \(index)"]
                return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
            }
        }
        
        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Error parsing JSON object."]
        return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
    }

    static func parseArray(string: String, inout startAt index: String.Index) -> FailableOf<JSValue> {
        index = index.successor()
        
        var values = [JSValue]()
        for ; index < string.endIndex; index = index.successor() {
            let c = string[index]
            
            if whitespace(c) { /* do nothing */ }
            else if c == "]" {
                index = index.successor()
                return FailableOf(JSValue(JSBackingValue.JSArray(values)))
            }
            else if c == "," { /* do nothing */ }
            else {
                let parsedValue = parse(string, startAt: &index)
                if parsedValue.failed { return parsedValue }
                if let value = parsedValue.value {
                    values.append(value)
                }
                
                index = index.predecessor()
            }
        }
        
        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Error parsing JSON array."]
        return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
    }
    
    static func parseNumber(string: String, inout startAt index: String.Index) -> FailableOf<JSValue> {
        enum ParsingState {
            case Initial
            case Whole
            case Decimal
            case Exponent
            case ExponentDigits
        }
        
        var state = ParsingState.Initial
        
        var number = 0.0
        var numberSign = 1.0
        var depth = 0.1
        var exponent = 0
        var exponentSign = 1
        
        for ; index < string.endIndex; index = index.successor() {
            let c = string[index]
            if c == "-" {
                switch state {
                case .Initial:
                    numberSign = -1
                    state = .Whole
                    
                case .Exponent:
                    exponentSign = -1
                    state = .ExponentDigits
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(c) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }
            }
            else if c == "+" {
                switch state {
                case .Initial:
                    state = .Whole
                    
                case .Exponent:
                    state = .ExponentDigits
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(c) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }
            }
            else if let digit = digit(c) {
                switch state {
                case .Initial:
                    state = .Whole
                    fallthrough
                    
                case .Whole:
                    number = number * 10 + Double(digit)
                    
                case .Decimal:
                    number = number + depth * Double(digit)
                    depth /= 10
                    
                case .Exponent:
                    state = .ExponentDigits
                    fallthrough
                    
                case .ExponentDigits:
                    exponent = exponent * 10 + digit
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(c) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }
            }
            else if c == "." {
                switch state {
                case .Whole:
                    state = .Decimal
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(c) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }
            }
            else if c == "e" || c == "E" {
                switch state {
                case .Whole:
                    state = .Exponent
                    
                case .Decimal:
                    state = .Exponent
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(c) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }
                state = ParsingState.Exponent
            }
            else {
                break
            }
        }

        return FailableOf(exp(number, exponent * exponentSign) * numberSign)
    }
    
    static func parseTrue(string: String, inout startAt index: String.Index) -> FailableOf<JSValue> {
        index = index.successor()
        
        if index >= string.endIndex || string[index] != "r" {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }
        
        index = index.successor()
        if index >= string.endIndex || string[index] != "u" {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }
        
        index = index.successor()
        if index >= string.endIndex || string[index] != "e" {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        
        let jsvalue: JSValue = true
        return FailableOf(jsvalue)
    }
    
    static func parseFalse(string: String, inout startAt index: String.Index) -> FailableOf<JSValue> {
        index = index.successor()
        
        if index >= string.endIndex || string[index] != "a" {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }
        
        index = index.successor()
        if index >= string.endIndex || string[index] != "l" {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }
        
        index = index.successor()
        if index >= string.endIndex || string[index] != "s" {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        if index != string.endIndex && string[index] != "e" && !whitespace(string[index]) {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        
        let jsvalue: JSValue = false
        return FailableOf(jsvalue)
    }
    
    static func parseNull(string: String, inout startAt index: String.Index) -> FailableOf<JSValue> {
        index = index.successor()
        
        if index >= string.endIndex || string[index] != "u" {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        if index >= string.endIndex || string[index] != "l" {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        if index >= string.endIndex || string[index] != "l" {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        
        let jsvalue: JSValue = nil
        return FailableOf(jsvalue)
    }
    
    static func parseString(string: String, inout startAt index: String.Index, quoteChar: Character) -> FailableOf<JSValue> {
        var value = ""
        
        index = index.successor()
        
        for ; index < string.endIndex; index = index.successor() {
            let c = string[index]
            if c == quoteChar && last(value) != "\\" {
                index = index.successor()
                return FailableOf(JSValue(JSBackingValue.JSString(value)))
            }
            else {
                value += c
            }
        }
        
        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Error parsing JSON string."]
        return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
    }
    
    static func exp(number: Double, _ exp: Int) -> Double {
        return exp < 0 ?
            reduce(0 ..< abs(exp), number, { x, _ in x / 10 }) :
            reduce(0 ..< exp, number, { x, _ in x * 10 })
    }
}