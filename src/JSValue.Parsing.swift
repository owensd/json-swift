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
        var index = string.utf8.startIndex
        let value = parse(string.utf8, startAt: &index)
        
        for ; index != string.utf8.endIndex; index = index.successor() {
            let cu = string.utf8[index]
            
            if !whitespace(cu) {
                var bytes = [UInt8]()
                var idx = index
                for var count = 0; idx != string.utf8.endIndex && count < 10; count++ {
                    bytes.append(string.utf8[idx])
                    idx = idx.successor()
                }
                bytes.append(0)
                
                let info = [
                    ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                    ErrorKeys.LocalizedFailureReason: "Invalid characters after the last item in the JSON: \(toString(bytes))"]
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
    static func parse(string: String.UTF8View, inout startAt index: String.UTF8View.Index) -> FailableOf<JSValue> {
        for ; index != string.endIndex; index = index.successor() {
            let cu = string[index]
            
            if whitespace(cu) { continue; }
            
            if cu == Token.LeftCurly.toRaw() {
                return parseObject(string, startAt: &index)
            }
            else if cu == Token.LeftBracket.toRaw() {
                return parseArray(string, startAt: &index)
            }
            else if digit(cu) != nil || cu == Token.Minus.toRaw() {
                return parseNumber(string, startAt: &index)
            }
            else if cu == Alphabet.t.toRaw() {
                return parseTrue(string, startAt: &index)
            }
            else if cu == Alphabet.f.toRaw() {
                return parseFalse(string, startAt: &index)
            }
            else if cu == Alphabet.n.toRaw() {
                return parseNull(string, startAt: &index)
            }
            else if cu == Token.DoubleQuote.toRaw() || cu == Token.SingleQuote.toRaw() {
                return parseString(string, startAt: &index, quote: cu)
            }
        }
        
        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "No valid JSON value was found to parse in string."]
        return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
    }

    static func parseObject(string: String.UTF8View, inout startAt index: String.UTF8View.Index) -> FailableOf<JSValue> {
        enum State {
            case Initial
            case Key
            case Value
        }
        
        index = index.successor()
        
        var state = State.Initial

        var key = ""
        var jsvalue = [String:JSValue]()
        while index != string.endIndex {
            let cu = string[index]
            
            if whitespace(cu) {
                index = index.successor()
            }
            else if cu == Token.RightCurly.toRaw() {
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
            else if cu == Token.SingleQuote.toRaw() || cu == Token.DoubleQuote.toRaw() {
                switch state {
                case .Initial:
                    state = .Key
                    
                    let parsedKey = parseString(string, startAt: &index, quote: cu)
                    if let error = parsedKey.error {
                        return FailableOf(error)
                    }
                    
                    if let parsedKey = parsedKey.value?.string {
                        key = parsedKey
                    }
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(cu) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }
            }
            else if cu == Token.Colon.toRaw() {
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

                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(cu) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }
            }
            else if cu == Token.Comma.toRaw() {
                switch state {
                case .Value:
                    state = .Initial
                    key = ""
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(cu) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }

                index = index.successor()
            }
            else {
                let info = [
                    ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                    ErrorKeys.LocalizedFailureReason: "Unexpected token: \(cu) @ \(index)"]
                return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
            }
        }
        
        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Error parsing JSON object."]
        return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
    }

    static func parseArray(string: String.UTF8View, inout startAt index: String.UTF8View.Index) -> FailableOf<JSValue> {
        index = index.successor()
        
        var values = [JSValue]()
        while index != string.endIndex {
            let c = string[index]
            
            if whitespace(c) || c == Token.Comma.toRaw() {
                index = index.successor()
            }
            else if c == Token.RightBracket.toRaw() {
                index = index.successor()
                return FailableOf(JSValue(JSBackingValue.JSArray(values)))
            }
            else {
                let parsedValue = parse(string, startAt: &index)
                if parsedValue.failed { return parsedValue }
                if let value = parsedValue.value {
                    values.append(value)
                }
            }
        }
        
        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Error parsing JSON array."]
        return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
    }
    
    static func parseNumber(string: String.UTF8View, inout startAt index: String.UTF8View.Index) -> FailableOf<JSValue> {
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
        
        while index != string.endIndex {
            let cu = string[index]
            
            if cu == Token.Minus.toRaw() {
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
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(cu) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }
                
                index = index.successor()
            }
            else if cu == Token.Plus.toRaw() {
                switch state {
                case .Initial:
                    state = .Whole
                    
                case .Exponent:
                    state = .ExponentDigits
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(cu) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }

                index = index.successor()
            }
            else if let digit = digit(cu) {
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
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(cu) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }

                index = index.successor()
            }
            else if cu == Token.Period.toRaw() {
                switch state {
                case .Whole:
                    state = .Decimal
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(cu) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }

                index = index.successor()
            }
            else if cu == Alphabet.e.toRaw() || cu == Alphabet.E.toRaw() {
                switch state {
                case .Whole:
                    state = .Exponent
                    
                case .Decimal:
                    state = .Exponent
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(cu) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }
                state = ParsingState.Exponent

                index = index.successor()
            }
            else {
                break
            }
        }

        return FailableOf(exp(number, exponent * exponentSign) * numberSign)
    }
    
    static func parseTrue(string: String.UTF8View, inout startAt index: String.UTF8View.Index) -> FailableOf<JSValue> {
        index = index.successor()
        
        if index != string.endIndex && string[index] != Alphabet.r.toRaw() {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }
        
        index = index.successor()
        if index != string.endIndex && string[index] != Alphabet.u.toRaw() {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }
        
        index = index.successor()
        if index != string.endIndex && string[index] != Alphabet.e.toRaw() {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        
        let jsvalue: JSValue = true
        return FailableOf(jsvalue)
    }
    
    static func parseFalse(string: String.UTF8View, inout startAt index: String.UTF8View.Index) -> FailableOf<JSValue> {
        index = index.successor()
        
        if index != string.endIndex && string[index] != Alphabet.a.toRaw() {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }
        
        index = index.successor()
        if index != string.endIndex && string[index] != Alphabet.l.toRaw() {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }
        
        index = index.successor()
        if index != string.endIndex && string[index] != Alphabet.s.toRaw() {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        if index != string.endIndex && string[index] != Alphabet.e.toRaw() && !whitespace(string[index]) {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        
        let jsvalue: JSValue = false
        return FailableOf(jsvalue)
    }
    
    static func parseNull(string: String.UTF8View, inout startAt index: String.UTF8View.Index) -> FailableOf<JSValue> {
        index = index.successor()
        
        if index != string.endIndex && string[index] != Alphabet.u.toRaw() {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        if index != string.endIndex && string[index] != Alphabet.l.toRaw() {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        if index != string.endIndex && string[index] != Alphabet.l.toRaw() {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(string[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        
        let jsvalue: JSValue = nil
        return FailableOf(jsvalue)
    }
    
    static func parseString(string: String.UTF8View, inout startAt index: String.UTF8View.Index, quote: UInt8) -> FailableOf<JSValue> {
        var bytes = [UInt8]()
        
        index = index.successor()
        for ; index != string.endIndex; index = index.successor() {
            let cu = string[index]
            if cu == quote {
                // Determine if the quote is being escaped or not...
                var count = 0
                for byte in reverse(bytes) {
                    if byte == Token.Backslash.toRaw() { count++ }
                    else { break }
                }

                if count % 2 == 0 {     // an even number means matched slashes, not an escape
                    index = index.successor()
                    
                    bytes.append(0)
                    let ptr = UnsafePointer<CChar>(bytes)
                    return FailableOf(JSValue(JSBackingValue.JSString(String.fromCString(ptr)!)))
                }
                else {
                    bytes.append(cu)
                }
            }
            else {
                bytes.append(cu)
            }
        }
        
        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Error parsing JSON string."]
        return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
    }
    
    // MARK: Helper functions
    
    static func whitespace(codeUnit: UInt8) -> Bool {
        return Whitespace.fromRaw(codeUnit).hasValue
    }
    
    static func digit(codeUnit: UInt8) -> Int? {
        if codeUnit >= Digit.Zero.toRaw() && codeUnit <= Digit.Nine.toRaw() {
            return codeUnit - Digit.Zero.toRaw()
        }
        
        return nil
    }

    static func toString(bytes: [UInt8]) -> String {
        let ptr = UnsafePointer<CChar>(bytes)
        return String.fromCString(ptr) ?? "<invalid string>"
    }
    
    static func toString(codeUnit: UInt8...) -> String {
        let bytes = codeUnit + [0]
        return toString(bytes)
    }
    
    static func exp(number: Double, _ exp: Int) -> Double {
        return exp < 0 ?
            reduce(0 ..< abs(exp), number, { x, _ in x / 10 }) :
            reduce(0 ..< exp, number, { x, _ in x * 10 })
    }
}

/// The code unit value for each of the digits.
enum Digit: UInt8 {
    case Zero   = 48
    case One
    case Two
    case Three
    case Four
    case Five
    case Six
    case Seven
    case Eight
    case Nine
}

/// The code unit value for each of the whitespace characters.
enum Whitespace: UInt8 {
    case Space               = 32
    case Tab                 = 9
    case CarriageReturn      = 13
    case Newline             = 10
}

/// The code unit value for all of the token characters used.
enum Token: UInt8 {
    case LeftBracket    = 91
    case RightBracket   = 93
    case LeftCurly      = 123
    case RightCurly     = 125
    case Comma          = 44
    case SingleQuote    = 39
    case DoubleQuote    = 34
    case Minus          = 45
    case Plus           = 43
    case Backslash      = 92
    case Colon          = 58
    case Period         = 46
}

/// The code unit value for the alphabet used as tokens.
enum Alphabet: UInt8 {
    case E      = 69
    case a      = 97
    case e      = 101
    case f      = 102
    case l      = 108
    case n      = 110
    case r      = 114
    case s      = 115
    case t      = 116
    case u      = 117
}