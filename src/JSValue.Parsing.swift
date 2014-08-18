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
        let scalars = string.unicodeScalars
        
        var index = scalars.startIndex
        let value = parse(scalars, startAt: &index)

        for ; index != scalars.endIndex; index = index.successor() {
            let scalar = scalars[index]
            
            if !scalar.isWhitespace() {
                var remainingText = substring(scalars, from: index)
                
                let info = [
                    ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                    ErrorKeys.LocalizedFailureReason: "Invalid characters after the last item in the JSON: \(remainingText)"]
                return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
            }
        }
        
        return value
    }
    
    /// Parses the given string and attempts to return a `JSValue` from it.
    ///
    /// :param: scalars the `String.UnicodeScalarView` that contains the JSON to parse.
    /// :param: startAt the index to start parsing the string from.
    ///
    /// :returns: A `FailableOf<T>` that will contain the parsed `JSValue` if successful,
    ///           otherwise, the `Error` information for the parsing.
    static func parse(scalars: String.UnicodeScalarView, inout startAt index: String.UnicodeScalarView.Index) -> FailableOf<JSValue> {
        for ; index != scalars.endIndex; index = index.successor() {
            let scalar = scalars[index]
            
            if scalar.isWhitespace() { continue; }
            
            if scalar == Token.LeftCurly {
                return parseObject(scalars, startAt: &index)
            }
            else if scalar == Token.LeftBracket {
                return parseArray(scalars, startAt: &index)
            }
            else if scalar.isDigit() || scalar == Token.Minus {
                return parseNumber(scalars, startAt: &index)
            }
            else if scalar == Token.t {
                return parseTrue(scalars, startAt: &index)
            }
            else if scalar == Token.f {
                return parseFalse(scalars, startAt: &index)
            }
            else if scalar == Token.n {
                return parseNull(scalars, startAt: &index)
            }
            else if scalar == Token.DoubleQuote || scalar == Token.SingleQuote {
                return parseString(scalars, startAt: &index, quote: scalar)
            }
        }
        
        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "No valid JSON value was found to parse in string."]
        return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
    }

    static func parseObject(scalars: String.UnicodeScalarView, inout startAt index: String.UnicodeScalarView.Index) -> FailableOf<JSValue> {
        enum State {
            case Initial
            case Key
            case Value
        }
        
        index = index.successor()
        
        var state = State.Initial

        var key = ""
        var jsvalue = [String:JSValue]()
        while index != scalars.endIndex {
            let scalar = scalars[index]
            
            if scalar.isWhitespace() {
                index = index.successor()
            }
            else if scalar == Token.RightCurly {
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
            else if scalar == Token.SingleQuote || scalar == Token.DoubleQuote {
                switch state {
                case .Initial:
                    state = .Key
                    
                    let parsedKey = parseString(scalars, startAt: &index, quote: scalar)
                    if let error = parsedKey.error {
                        return FailableOf(error)
                    }
                    
                    if let parsedKey = parsedKey.value?.string {
                        key = parsedKey
                    }
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalar) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }
            }
            else if scalar == Token.Colon {
                switch state {
                case .Key:
                    state = .Value
                    
                    let parsedValue = parse(scalars, startAt: &index)
                    if parsedValue.failed {
                        return parsedValue
                    }
                    else if let value = parsedValue.value {
                        jsvalue[key] = value
                    }

                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalar) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }
            }
            else if scalar == Token.Comma {
                switch state {
                case .Value:
                    state = .Initial
                    key = ""
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalar) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }

                index = index.successor()
            }
            else {
                let info = [
                    ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                    ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalar) @ \(index)"]
                return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
            }
        }
        
        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Error parsing JSON object."]
        return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
    }

    static func parseArray(scalars: String.UnicodeScalarView, inout startAt index: String.UnicodeScalarView.Index) -> FailableOf<JSValue> {
        index = index.successor()
        
        var values = [JSValue]()
        while index != scalars.endIndex {
            let scalar = scalars[index]
            
            if scalar.isWhitespace() || scalar == Token.Comma {
                index = index.successor()
            }
            else if scalar == Token.RightBracket {
                index = index.successor()
                return FailableOf(JSValue(JSBackingValue.JSArray(values)))
            }
            else {
                let parsedValue = parse(scalars, startAt: &index)
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
    
    static func parseNumber(scalars: String.UnicodeScalarView, inout startAt index: String.UnicodeScalarView.Index) -> FailableOf<JSValue> {
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
        
        while index != scalars.endIndex {
            let scalar = scalars[index]
            
            if scalar == Token.Minus {
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
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalar) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }
                
                index = index.successor()
            }
            else if scalar == Token.Plus {
                switch state {
                case .Initial:
                    state = .Whole
                    
                case .Exponent:
                    state = .ExponentDigits
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalar) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }

                index = index.successor()
            }
            else if scalar.isDigit() {
                switch state {
                case .Initial:
                    state = .Whole
                    fallthrough
                    
                case .Whole:
                    number = number * 10 + Double(scalar.value - Token.Zero.value)
                    
                case .Decimal:
                    number = number + depth * Double(scalar.value - Token.Zero.value)
                    depth /= 10
                    
                case .Exponent:
                    state = .ExponentDigits
                    fallthrough
                    
                case .ExponentDigits:
                    exponent = exponent * 10 + scalar.value - Token.Zero.value
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalar) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }

                index = index.successor()
            }
            else if scalar == Token.Period {
                switch state {
                case .Whole:
                    state = .Decimal
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalar) @ \(index)"]
                    return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
                }

                index = index.successor()
            }
            else if scalar == Token.e || scalar == Token.E {
                switch state {
                case .Whole:
                    state = .Exponent
                    
                case .Decimal:
                    state = .Exponent
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalar) @ \(index)"]
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
    
    static func parseTrue(scalars: String.UnicodeScalarView, inout startAt index: String.UnicodeScalarView.Index) -> FailableOf<JSValue> {
        index = index.successor()
        
        if index != scalars.endIndex && scalars[index] != Token.r {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalars[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }
        
        index = index.successor()
        if index != scalars.endIndex && scalars[index] != Token.u {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalars[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }
        
        index = index.successor()
        if index != scalars.endIndex && scalars[index] != Token.e {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalars[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        
        let jsvalue: JSValue = true
        return FailableOf(jsvalue)
    }
    
    static func parseFalse(scalars: String.UnicodeScalarView, inout startAt index: String.UnicodeScalarView.Index) -> FailableOf<JSValue> {
        index = index.successor()
        
        if index != scalars.endIndex && scalars[index] != Token.a {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalars[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }
        
        index = index.successor()
        if index != scalars.endIndex && scalars[index] != Token.l {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalars[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }
        
        index = index.successor()
        if index != scalars.endIndex && scalars[index] != Token.s {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalars[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        let scalar = scalars[index]
        if index != scalars.endIndex && scalar != Token.e && !scalar.isWhitespace() {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalars[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        
        let jsvalue: JSValue = false
        return FailableOf(jsvalue)
    }
    
    static func parseNull(scalars: String.UnicodeScalarView, inout startAt index: String.UnicodeScalarView.Index) -> FailableOf<JSValue> {
        index = index.successor()
        
        if index != scalars.endIndex && scalars[index] != Token.u {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalars[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        if index != scalars.endIndex && scalars[index] != Token.l {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalars[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        if index != scalars.endIndex && scalars[index] != Token.l {
            let info = [
                ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                ErrorKeys.LocalizedFailureReason: "Unexpected token: \(scalars[index])"]
            return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
        }

        index = index.successor()
        
        let jsvalue: JSValue = nil
        return FailableOf(jsvalue)
    }
    
    static func parseString(scalars: String.UnicodeScalarView, inout startAt index: String.UnicodeScalarView.Index, quote: UnicodeScalar) -> FailableOf<JSValue> {
        var stream = ""
        var escapeCount = 0
        
        index = index.successor()
        for ; index != scalars.endIndex; index = index.successor() {
            let scalar = scalars[index]
            if scalar == quote {
                if escapeCount % 2 == 0 {
                    index = index.successor()
                    return FailableOf(JSValue(JSBackingValue.JSString(stream)))
                }
                else {
                    escapeCount = 0
                    scalar.writeTo(&stream)
                }
            }
            else {
                escapeCount = scalar == Token.Backslash ? escapeCount + 1 : 0
                scalar.writeTo(&stream)
            }
        }
        
        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Error parsing JSON string."]
        return FailableOf(Error(code: ErrorCode.ParsingError, domain: JSValueErrorDomain, userInfo: info))
    }
    
    // MARK: Helper functions
    
    static func substring(scalars: String.UnicodeScalarView, from: String.UnicodeScalarView.Index) -> String {
        var idx = from
        var string = ""
        while idx != scalars.endIndex {
            let scalar = scalars[idx]
            scalar.writeTo(&string)
            
            idx = idx.successor()
        }
        
        return string
    }
    
    static func exp(number: Double, _ exp: Int) -> Double {
        return exp < 0 ?
            reduce(0 ..< abs(exp), number, { x, _ in x / 10 }) :
            reduce(0 ..< exp, number, { x, _ in x * 10 })
    }
}

extension UnicodeScalar {
    
    /// Determines if the `UnicodeScalar` represents one of the standard Unicode whitespace characters.
    ///
    /// :return: `true` if the scalar is a Unicode whitespace character; `false` otherwise.
    func isWhitespace() -> Bool {
        if value >= 0x09 && value <= 0x0D       { return true }     // White_Space # Cc   [5] <control-0009>..<control-000D>
        if value == 0x20                        { return true }     // White_Space # Zs       SPACE
        if value == 0x85                        { return true }     // White_Space # Cc       <control-0085>
        if value == 0xA0                        { return true }     // White_Space # Zs       NO-BREAK SPACE
        if value == 0x1680                      { return true }     // White_Space # Zs       OGHAM SPACE MARK
        if value >= 0x2000 && value <= 0x200A   { return true }     // White_Space # Zs  [11] EN QUAD..HAIR SPACE
        if value == 0x2028                      { return true }     // White_Space # Zl       LINE SEPARATOR
        if value == 0x2029                      { return true }     // White_Space # Zp       PARAGRAPH SEPARATOR
        if value == 0x202F                      { return true }     // White_Space # Zs       NARROW NO-BREAK SPACE
        if value == 0x205F                      { return true }     // White_Space # Zs       MEDIUM MATHEMATICAL SPACE
        if value == 0x3000                      { return true }     // White_Space # Zs       IDEOGRAPHIC SPACE

        return false
    }
    
    /// Determines if the `UnicodeScalar` respresents a numeric digit.
    ///
    /// :return: `true` if the scalar is a Unicode numeric character; `false` otherwise.
    func isDigit() -> Bool {
        return value >= Token.Zero.value && value <= Token.Nine.value
    }
    

}

/// The code unit value for all of the token characters used.
struct Token {
    private init() {}
    
    // Tokens for JSON
    static let LeftBracket      = UnicodeScalar(91)
    static let RightBracket     = UnicodeScalar(93)
    static let LeftCurly        = UnicodeScalar(123)
    static let RightCurly       = UnicodeScalar(125)
    static let Comma            = UnicodeScalar(44)
    static let SingleQuote      = UnicodeScalar(39)
    static let DoubleQuote      = UnicodeScalar(34)
    static let Minus            = UnicodeScalar(45)
    static let Plus             = UnicodeScalar(43)
    static let Backslash        = UnicodeScalar(92)
    static let Colon            = UnicodeScalar(58)
    static let Period           = UnicodeScalar(46)
    
    // Numbers
    static let Zero             = UnicodeScalar(48)
    static let One              = UnicodeScalar(49)
    static let Two              = UnicodeScalar(50)
    static let Three            = UnicodeScalar(51)
    static let Four             = UnicodeScalar(52)
    static let Five             = UnicodeScalar(53)
    static let Six              = UnicodeScalar(54)
    static let Seven            = UnicodeScalar(55)
    static let Eight            = UnicodeScalar(56)
    static let Nine             = UnicodeScalar(57)
    
    // Character tokens for JSON
    static let E                = UnicodeScalar(69)
    static let a                = UnicodeScalar(97)
    static let e                = UnicodeScalar(101)
    static let f                = UnicodeScalar(102)
    static let l                = UnicodeScalar(108)
    static let n                = UnicodeScalar(110)
    static let r                = UnicodeScalar(114)
    static let s                = UnicodeScalar(115)
    static let t                = UnicodeScalar(116)
    static let u                = UnicodeScalar(117)
}
