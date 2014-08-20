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
        var generator = ReplayableGenerator(string.unicodeScalars)
        let value = parse(generator)
        
        for scalar in generator {
            if scalar.isWhitespace() { continue }
            else {
                var remainingText = substring(generator)
                
                let info = [
                    ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                    ErrorKeys.LocalizedFailureReason: "Invalid characters after the last item in the JSON: \(remainingText)"]
                return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
            }
        }
        
        return value
    }
    
    /// Parses the given string and attempts to return a `JSValue` from it.
    ///
    /// :param: generator the `ReplayableGenerator<String.UnicodeScalarView>` that contains the JSON to parse.
    ///
    /// :returns: A `FailableOf<T>` that will contain the parsed `JSValue` if successful,
    ///           otherwise, the `Error` information for the parsing.
    static func parse(generator: ReplayableGenerator<String.UnicodeScalarView>) -> FailableOf<JSValue> {
        for scalar in generator {
            if scalar.isWhitespace() { continue }
            
            if scalar == Token.LeftCurly {
                return parseObject(generator)
            }
            else if scalar == Token.LeftBracket {
                return parseArray(generator)
            }
            else if scalar.isDigit() || scalar == Token.Minus {
                return parseNumber(generator)
            }
            else if scalar == Token.t {
                return parseTrue(generator)
            }
            else if scalar == Token.f {
                return parseFalse(generator)
            }
            else if scalar == Token.n {
                return parseNull(generator)
            }
            else if scalar == Token.DoubleQuote || scalar == Token.SingleQuote {
                return parseString(generator, quote: scalar)
            }
        }
        
        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "No valid JSON value was found to parse in string."]
        return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
    }

    static func parseObject(generator: ReplayableGenerator<String.UnicodeScalarView>) -> FailableOf<JSValue> {
        enum State {
            case Initial
            case Key
            case Value
        }
        
        var state = State.Initial

        var key = ""
        var jsvalue = [String:JSValue]()

        for (idx, scalar) in enumerate(generator) {
            switch (idx, scalar) {
            case (0, Token.LeftCurly): continue
            case (_, Token.RightCurly):
                switch state {
                case .Initial: fallthrough
                case .Value:
                    generator.next()        // eat the '}'
                    return FailableOf(JSValue(JSBackingValue.JSObject(jsvalue)))
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Expected token '}' at index: \(idx). Token: \(scalar). Context: '\(contextualString(generator))'."]
                    return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }

            case (_, Token.SingleQuote): fallthrough
            case (_, Token.DoubleQuote):
                switch state {
                case .Initial:
                    state = .Key
                    
                    let parsedKey = parseString(generator, quote: scalar)
                    if let parsedKey = parsedKey.value?.string {
                        key = parsedKey
                        generator.replay()
                    }
                    else {
                        return FailableOf(parsedKey.error!)
                    }
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Expected token ''' (single quote) or '\"' at index: \(idx). Token: \(scalar). Context: '\(contextualString(generator))'."]
                    return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }

            case (_, Token.Colon):
                switch state {
                case .Key:
                    state = .Value
                    
                    let parsedValue = parse(generator)
                    if let value = parsedValue.value {
                        jsvalue[key] = value
                        generator.replay()
                    }
                    else {
                        return FailableOf(parsedValue.error!)
                    }

                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Expected token ':' at index: \(idx). Token: \(scalar). Context: '\(contextualString(generator))'."]
                    return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }

            case (_, Token.Comma):
                switch state {
                case .Value:
                    state = .Initial
                    key = ""
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Expected token ',' at index: \(idx). Token: \(scalar). Context: '\(contextualString(generator))'."]
                    return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }

            default:
                if scalar.isWhitespace() { continue }
                else {
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token at index: \(idx). Token: \(scalar). Context: '\(contextualString(generator))'."]
                    return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }
            }
        }
        
        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Unable to parse object. Context: '\(contextualString(generator))'."]
        return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
    }

    static func parseArray(generator: ReplayableGenerator<String.UnicodeScalarView>) -> FailableOf<JSValue> {
        var values = [JSValue]()

        for (idx, scalar) in enumerate(generator) {
            switch (idx, scalar) {
            case (0, Token.LeftBracket): continue
            case (_, Token.RightBracket):
                generator.next()        // eat the ']'
                return FailableOf(JSValue(JSBackingValue.JSArray(values)))

            case (_, _):
                if scalar.isWhitespace() || scalar == Token.Comma { continue }
                else {
                    let parsedValue = parse(generator)
                    if let value = parsedValue.value {
                        values.append(value)
                        generator.replay()
                    }
                    else {
                        return FailableOf(parsedValue.error!)
                    }
                }
            }
        }
        
        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Unable to parse array. Context: '\(contextualString(generator))'."]
        return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
    }
    
    static func parseNumber(generator: ReplayableGenerator<String.UnicodeScalarView>) -> FailableOf<JSValue> {
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
        
        for (idx, scalar) in enumerate(generator) {
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
                        ErrorKeys.LocalizedFailureReason: "Expected token '-' at index: \(idx). Token: \(scalar). Context: '\(contextualString(generator))'."]
                    return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }
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
                        ErrorKeys.LocalizedFailureReason: "Expected token '+' at index: \(idx). Token: \(scalar). Context: '\(contextualString(generator))'."]
                    return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }
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
                        ErrorKeys.LocalizedFailureReason: "Expected valid digit at index: \(idx). Token: \(scalar). Context: '\(contextualString(generator))'."]
                    return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }
            }
            else if scalar == Token.Period {
                switch state {
                case .Whole:
                    state = .Decimal
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Expected token '.' at index: \(idx). Token: \(scalar). Context: '\(contextualString(generator))'."]
                    return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }
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
                        ErrorKeys.LocalizedFailureReason: "Expected token 'e' or 'E' at index: \(idx). Token: \(scalar). Context: '\(contextualString(generator))'."]
                    return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }
                state = ParsingState.Exponent
            }
            else {
                break
            }
        }

        let jsvalue = JSValue(JSBackingValue.JSNumber(exp(number, exponent * exponentSign) * numberSign))
        return FailableOf(jsvalue)
    }
    
    static func parseTrue(generator: ReplayableGenerator<String.UnicodeScalarView>) -> FailableOf<JSValue> {
        for (idx, scalar) in enumerate(generator) {
            switch (idx, scalar) {
            case (0, Token.t): continue
            case (1, Token.r): continue
            case (2, Token.u): continue
            case (3, Token.e): continue
            case (4, _):
                if scalar.isValidTerminator() { return FailableOf(true) }
                fallthrough

            default:
                let info = [
                    ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                    ErrorKeys.LocalizedFailureReason: "Unexpected token at index: \(idx). Token: \(scalar). Context: '\(contextualString(generator))'."]
                return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
            }
        }

        if generator.atEnd() { return FailableOf(true) }

        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Unable to parse 'true' literal. Context: '\(contextualString(generator))'."]
        return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
    }
    
    static func parseFalse(generator: ReplayableGenerator<String.UnicodeScalarView>) -> FailableOf<JSValue> {
        for (idx, scalar) in enumerate(generator) {
            switch (idx, scalar) {
            case (0, Token.f): continue
            case (1, Token.a): continue
            case (2, Token.l): continue
            case (3, Token.s): continue
            case (4, Token.e): continue
            case (5, _):
                if scalar.isValidTerminator() { return FailableOf(false) }
                fallthrough

            default:
                let info = [
                    ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                    ErrorKeys.LocalizedFailureReason: "Unexpected token at index: \(idx). Token: \(scalar). Context: '\(contextualString(generator))'."]
                return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
            }
        }

        if generator.atEnd() { return FailableOf(false) }

        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Unable to parse 'false' literal. Context: '\(contextualString(generator))'."]
        return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
    }
    
    static func parseNull(generator: ReplayableGenerator<String.UnicodeScalarView>) -> FailableOf<JSValue> {
        for (idx, scalar) in enumerate(generator) {
            switch (idx, scalar) {
            case (0, Token.n): continue
            case (1, Token.u): continue
            case (2, Token.l): continue
            case (3, Token.l): continue
            case (4, _):
                if scalar.isValidTerminator() { return FailableOf(nil) }
                fallthrough

            default:
                let info = [
                    ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                    ErrorKeys.LocalizedFailureReason: "Unexpected token at index: \(idx). Token: \(scalar). Context: '\(contextualString(generator))'."]
                return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
            }
        }

        if generator.atEnd() { return FailableOf(nil) }

        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Unable to parse 'null' literal. Context: '\(contextualString(generator))'."]
        return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
    }
    
    static func parseString(generator: ReplayableGenerator<String.UnicodeScalarView>, quote: UnicodeScalar) -> FailableOf<JSValue> {
        var string = ""
        var escapeCount = 0

        for (idx, scalar) in enumerate(generator) {
            switch (idx, scalar) {
            case (0, quote): continue
            case (_, quote):
                if escapeCount % 2 == 0 {
                    generator.next()        // eat the quote
                    return FailableOf(JSValue(JSBackingValue.JSString(string)))
                }
                else {
                    escapeCount = 0
                    scalar.writeTo(&string)
                }

            default:
                escapeCount = scalar == Token.Backslash ? escapeCount + 1 : 0
                scalar.writeTo(&string)
            }
        }

        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Unable to parse string. Context: '\(contextualString(generator))'."]
        return FailableOf(Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
    }
    

    // MARK: Helper functions

    static func substring(generator: ReplayableGenerator<String.UnicodeScalarView>) -> String {
        var string = ""

        for scalar in generator {
            scalar.writeTo(&string)
        }
        
        return string
    }


    static func contextualString(generator: ReplayableGenerator<String.UnicodeScalarView>, left: Int = 5, right: Int = 10) -> String {
        var string = ""

        for var i = left; i > 0; i-- {
            generator.replay()
        }

        for var i = 0; i < (left + right); i++ {
            let scalar = generator.next()
            scalar?.writeTo(&string)
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

    /// Determines if the `UnicodeScalar` respresents a valid terminating character.
    /// :return: `true` if the scalar is a valid terminator, `false` otherwise.
    func isValidTerminator() -> Bool {
        if self == Token.Comma            { return true }
        if self == Token.RightBracket     { return true }
        if self == Token.RightCurly       { return true }
        if self.isWhitespace()            { return true }

        return false
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
