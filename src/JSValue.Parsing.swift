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
                return FailableOf(Error(code: 0, domain: "", userInfo: nil))
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
        }
        
        return FailableOf(Error(code: 0, domain: "", userInfo: nil))
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
        index = index.successor()
        
        var jsvalue: JSValue = [:]
        for ; index < string.endIndex; index = index.successor() {
            let c = string[index]
            
            if whitespace(c) { /* do nothing */ }
            else if c == "\"" {
                var key = ""
                for ; index < string.endIndex; index.successor() {
                    let c = string[index]
                    if c != "\"" { key += c } else { break }
                }
                
                for ; index < string.endIndex; index.successor() {
                    if whitespace(string[index]) { continue }
                }
                
                if index < string.endIndex && string[index] != ":" {
                    return FailableOf(Error(code: 0, domain: "bad key", userInfo: nil))
                }
                
                for ; index < string.endIndex; index.successor() {
                    if whitespace(string[index]) { continue; }
                }
                
                let value = parse(string, startAt: &index)
                if let error = jsvalue.error { return value }
                if let value = value.value {
                    jsvalue[key] = value
                }
            }
            else if c == "\'" { }
            else if c == "}" {
                index = index.successor()
                return FailableOf(jsvalue)
            }
        }
        
        return FailableOf(Error(code: 0, domain: "nyi", userInfo: nil))
    }

    static func parseArray(string: String, inout startAt index: String.Index) -> FailableOf<JSValue> {
        index = index.successor()
        
        var values = [JSValue]()
        for ; index < string.endIndex; index = index.successor() {
            let c = string[index]
            
            if c == "]" {
                index = index.successor()
                return FailableOf(JSValue(JSBackingValue.JSArray(values)))
            }
            
            let value = parse(string, startAt: &index)
            if value.failed { return value }
            if let value = value.value {
                values.append(value)
            }
            
            if index < string.endIndex && string[index] == "]" {
                index = index.successor()
                return FailableOf(JSValue(JSBackingValue.JSArray(values)))
            }
        }
        
        return FailableOf(Error(code: 0, domain: "nyi", userInfo: nil))
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
                    return FailableOf(Error(code: 0, domain: "nyi", userInfo: nil))
                }
            }
            else if c == "+" {
                switch state {
                case .Initial:
                    state = .Whole
                    
                case .Exponent:
                    state = .ExponentDigits
                    
                default:
                    return FailableOf(Error(code: 0, domain: "nyi", userInfo: nil))
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
                    return FailableOf(Error(code: 0, domain: "nyi", userInfo: nil))
                }
            }
            else if c == "." {
                switch state {
                case .Whole:
                    state = .Decimal
                    
                default:
                    return FailableOf(Error(code: 0, domain: "nyi", userInfo: nil))
                }
            }
            else if c == "e" || c == "E" {
                switch state {
                case .Whole:
                    state = .Exponent
                    
                case .Decimal:
                    state = .Exponent
                    
                default:
                    return FailableOf(Error(code: 0, domain: "nyi", userInfo: nil))
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
            return FailableOf(Error(code: 0, domain: "bad null", userInfo: nil))
        }
        
        index = index.successor()
        if index >= string.endIndex || string[index] != "u" {
            return FailableOf(Error(code: 0, domain: "bad null", userInfo: nil))
        }
        
        index = index.successor()
        if index >= string.endIndex || string[index] != "e" {
            return FailableOf(Error(code: 0, domain: "bad null", userInfo: nil))
        }

        index = index.successor()
        
        let jsvalue: JSValue = true
        return FailableOf(jsvalue)
    }
    
    static func parseFalse(string: String, inout startAt index: String.Index) -> FailableOf<JSValue> {
        index = index.successor()
        
        if index >= string.endIndex || string[index] != "a" {
            return FailableOf(Error(code: 0, domain: "bad null", userInfo: nil))
        }
        
        index = index.successor()
        if index >= string.endIndex || string[index] != "l" {
            return FailableOf(Error(code: 0, domain: "bad null", userInfo: nil))
        }
        
        index = index.successor()
        if index >= string.endIndex || string[index] != "s" {
            return FailableOf(Error(code: 0, domain: "bad null", userInfo: nil))
        }

        index = index.successor()
        if index != string.endIndex && string[index] != "e" && !whitespace(string[index]) {
            return FailableOf(Error(code: 0, domain: "bad null", userInfo: nil))
        }

        index = index.successor()
        
        let jsvalue: JSValue = false
        return FailableOf(jsvalue)
    }
    
    static func parseNull(string: String, inout startAt index: String.Index) -> FailableOf<JSValue> {
        index = index.successor()
        
        if index >= string.endIndex || string[index] != "u" {
            return FailableOf(Error(code: 0, domain: "bad null", userInfo: nil))
        }

        index = index.successor()
        if index >= string.endIndex || string[index] != "l" {
            return FailableOf(Error(code: 0, domain: "bad null", userInfo: nil))
        }

        index = index.successor()
        if index >= string.endIndex || string[index] != "l" {
            return FailableOf(Error(code: 0, domain: "bad null", userInfo: nil))
        }

        index = index.successor()
        
        let jsvalue: JSValue = nil
        return FailableOf(jsvalue)
    }
    
    static func exp(number: Double, _ exp: Int) -> Double {
        let sign = exp < 0 ? -1 : 1
        let coefficient = exp * sign
        let mult = reduce(0 ..< coefficient, 1, { x, _ in x * 10 })
        
        return sign < 0 ? number / Double(mult) : number * Double(mult)
    }
}