//
//  JSValue.Parsing.swift
//  JSON
//
//  Created by David Owens II on 8/12/14.
//  Copyright (c) 2014 David Owens II. All rights reserved.
//

import Foundation

extension JSValue {
    /// The type that represents the result of the parse.
    public typealias JSParsingResult = (value: JSValue?, error: Error?)

    public typealias JSParsingSequence = UnsafeBufferPointer<UInt8>


    public static func parse(string: String) -> JSParsingResult {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        return parse(data)
    }

    public static func parse(data: NSData) -> JSParsingResult {
        let ptr = UnsafePointer<UInt8>(data.bytes)
        let bytes = UnsafeBufferPointer<UInt8>(start: ptr, count: data.length)

        return parse(bytes)
    }

    /// Parses the given sequence of UTF8 code points and attempts to return a `JSValue` from it.
    ///
    /// - parameter seq: The sequence of UTF8 code points.
    ///
    /// - returns: A `JSParsingResult` containing the parsed `JSValue` or error information.
    public static func parse(seq: JSParsingSequence) -> JSParsingResult {
        let generator = ReplayableGenerator(seq)

        let result = parse(generator)
        if let value = result.value {
            for codeunit in generator {
                if codeunit.isWhitespace() { continue }
                else {
                    let remainingText = substring(generator)
                    
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Invalid characters after the last item in the JSON: \(remainingText)"]
                    return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }
            }

            return (value, nil)
        }
        
        return result
    }

    static func parse<S: SequenceType where S.Generator.Element == UInt8>(generator: ReplayableGenerator<S>) -> JSParsingResult {
        for codeunit in generator {
            if codeunit.isWhitespace() { continue }
            
            if codeunit == Token.LeftCurly {
                return JSValue.parseObject(generator)
            }
            else if codeunit == Token.LeftBracket {
                return JSValue.parseArray(generator)
            }
            else if codeunit.isDigit() || codeunit == Token.Minus {
                return JSValue.parseNumber(generator)
            }
            else if codeunit == Token.t {
                return JSValue.parseTrue(generator)
            }
            else if codeunit == Token.f {
                return JSValue.parseFalse(generator)
            }
            else if codeunit == Token.n {
                return JSValue.parseNull(generator)
            }
            else if codeunit == Token.DoubleQuote || codeunit == Token.SingleQuote {
                return JSValue.parseString(generator, quote: codeunit)
            }
        }

        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "No valid JSON value was found to parse in string."]
        return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
    }

    enum ObjectParsingState {
        case Initial
        case Key
        case Value
    }
    static func parseObject<S: SequenceType where S.Generator.Element == UInt8>(generator: ReplayableGenerator<S>) -> JSParsingResult {
        var state = ObjectParsingState.Initial

        var key = ""
        var object = JSObjectType()

        for (idx, codeunit) in generator.enumerate() {
            switch (idx, codeunit) {
            case (0, Token.LeftCurly): continue
            case (_, Token.RightCurly):
                switch state {
                case .Initial: fallthrough
                case .Value:
                    generator.next()        // eat the '}'
                    return (JSValue(object), nil)
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Expected token '}' at index: \(idx). Token: \(codeunit). Context: '\(contextualString(generator))'."]
                    return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }

            case (_, Token.SingleQuote): fallthrough
            case (_, Token.DoubleQuote):
                switch state {
                case .Initial:
                    state = .Key
                    
                    let parsedKey = parseString(generator, quote: codeunit)
                    if let parsedKey = parsedKey.value?.string {
                        key = parsedKey
                        generator.replay()
                    }
                    else {
                        return (nil, parsedKey.error)
                    }
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Expected token ''' (single quote) or '\"' at index: \(idx). Token: \(codeunit). Context: '\(contextualString(generator))'."]
                    return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }

            case (_, Token.Colon):
                switch state {
                case .Key:
                    state = .Value
                    
                    let parsedValue = parse(generator)
                    if let value = parsedValue.value {
                        object[key] = value
                        generator.replay()
                    }
                    else {
                        return (nil, parsedValue.error)
                    }

                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Expected token ':' at index: \(idx). Token: \(codeunit). Context: '\(contextualString(generator))'."]
                    return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }

            case (_, Token.Comma):
                switch state {
                case .Value:
                    state = .Initial
                    key = ""
                    
                default:
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Expected token ',' at index: \(idx). Token: \(codeunit). Context: '\(contextualString(generator))'."]
                    return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }

            default:
                if codeunit.isWhitespace() { continue }
                else {
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token at index: \(idx). Token: \(codeunit). Context: '\(contextualString(generator))'."]
                    return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }
            }
        }
        
        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Unable to parse object. Context: '\(contextualString(generator))'."]
        return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
    }

    static func parseArray<S: SequenceType where S.Generator.Element == UInt8>(generator: ReplayableGenerator<S>) -> JSParsingResult {
        var values = [JSValue]()

        for (idx, codeunit) in generator.enumerate() {
            switch (idx, codeunit) {
            case (0, Token.LeftBracket): continue
            case (_, Token.RightBracket):
                generator.next()        // eat the ']'
                return (JSValue(JSBackingValue.JSArray(values)), nil)

            default:
                if codeunit.isWhitespace() || codeunit == Token.Comma { continue }
                else {
                    let parsedValue = parse(generator)
                    if let value = parsedValue.value {
                        values.append(value)
                        generator.replay()
                    }
                    else {
                        return (nil, parsedValue.error)
                    }
                }
            }
        }
        
        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Unable to parse array. Context: '\(contextualString(generator))'."]
        return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
    }

    enum NumberParsingState {
        case Initial
        case Whole
        case Decimal
        case Exponent
        case ExponentDigits
    }
    static func parseNumber<S: SequenceType where S.Generator.Element == UInt8>(generator: ReplayableGenerator<S>) -> JSParsingResult {
        var state = NumberParsingState.Initial
        
        var number = 0.0
        var numberSign = 1.0
        var depth = 0.1
        var exponent = 0
        var exponentSign = 1
        
        for (idx, codeunit) in generator.enumerate() {
            switch (idx, codeunit, state) {
            case (0, Token.Minus, NumberParsingState.Initial):
                numberSign = -1
                state = .Whole

            case (_, Token.Minus, NumberParsingState.Exponent):
                exponentSign = -1
                state = .ExponentDigits

            case (_, Token.Plus, NumberParsingState.Initial):
                state = .Whole

            case (_, Token.Plus, NumberParsingState.Exponent):
                state = .ExponentDigits

            case (_, Token.Zero...Token.Nine, NumberParsingState.Initial):
                state = .Whole
                fallthrough

            case (_, Token.Zero...Token.Nine, NumberParsingState.Whole):
                number = number * 10 + Double(codeunit - Token.Zero)
                    
            case (_, Token.Zero...Token.Nine, NumberParsingState.Decimal):
                number = number + depth * Double(codeunit - Token.Zero)
                depth /= 10
                    
            case (_, Token.Zero...Token.Nine, NumberParsingState.Exponent):
                state = .ExponentDigits
                fallthrough
                    
            case (_, Token.Zero...Token.Nine, NumberParsingState.ExponentDigits):
                exponent = exponent * 10 + Int(codeunit) - Int(Token.Zero)

            case (_, Token.Period, NumberParsingState.Whole):
                state = .Decimal

            case (_, Token.e, NumberParsingState.Whole):      state = .Exponent
            case (_, Token.E, NumberParsingState.Whole):      state = .Exponent
            case (_, Token.e, NumberParsingState.Decimal):    state = .Exponent
            case (_, Token.E, NumberParsingState.Decimal):    state = .Exponent
                    
            default:
                if codeunit.isValidTerminator() {
                    return (JSValue(JSBackingValue.JSNumber(exp(number, exponent * exponentSign) * numberSign)), nil)
                }
                else {
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token at index: \(idx). Token: \(codeunit). State: \(state). Context: '\(contextualString(generator))'."]
                    return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }
            }
        }

        if generator.atEnd() { return (JSValue(exp(number, exponent * exponentSign) * numberSign), nil) }

        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Unable to parse array. Context: '\(contextualString(generator))'."]
        return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
    }
    
    static func parseTrue<S: SequenceType where S.Generator.Element == UInt8>(generator: ReplayableGenerator<S>) -> JSParsingResult {
        for (idx, codeunit) in generator.enumerate() {
            switch (idx, codeunit) {
            case (0, Token.t): continue
            case (1, Token.r): continue
            case (2, Token.u): continue
            case (3, Token.e): continue
            case (4, _):
                if codeunit.isValidTerminator() { return (JSValue(true), nil) }
                fallthrough

            default:
                let info = [
                    ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                    ErrorKeys.LocalizedFailureReason: "Unexpected token at index: \(idx). Token: \(codeunit). Context: '\(contextualString(generator))'."]
                return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
            }
        }

        if generator.atEnd() { return (JSValue(true), nil) }

        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Unable to parse 'true' literal. Context: '\(contextualString(generator))'."]
        return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
    }
    
    static func parseFalse<S: SequenceType where S.Generator.Element == UInt8>(generator: ReplayableGenerator<S>) -> JSParsingResult {
        for (idx, codeunit) in generator.enumerate() {
            switch (idx, codeunit) {
            case (0, Token.f): continue
            case (1, Token.a): continue
            case (2, Token.l): continue
            case (3, Token.s): continue
            case (4, Token.e): continue
            case (5, _):
                if codeunit.isValidTerminator() { return (JSValue(false), nil) }
                fallthrough

            default:
                let info = [
                    ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                    ErrorKeys.LocalizedFailureReason: "Unexpected token at index: \(idx). Token: \(codeunit). Context: '\(contextualString(generator))'."]
                return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
            }
        }

        if generator.atEnd() { return (JSValue(false), nil) }

        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Unable to parse 'false' literal. Context: '\(contextualString(generator))'."]
        return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
    }
    
    static func parseNull<S: SequenceType where S.Generator.Element == UInt8>(generator: ReplayableGenerator<S>) -> JSParsingResult {
        for (idx, codeunit) in generator.enumerate() {
            switch (idx, codeunit) {
            case (0, Token.n): continue
            case (1, Token.u): continue
            case (2, Token.l): continue
            case (3, Token.l): continue
            case (4, _):
                if codeunit.isValidTerminator() { return (JSValue(JSBackingValue.JSNull), nil) }
                fallthrough

            default:
                let info = [
                    ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                    ErrorKeys.LocalizedFailureReason: "Unexpected token at index: \(idx). Token: \(codeunit). Context: '\(contextualString(generator))'."]
                return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
            }
        }

        if generator.atEnd() { return (JSValue(JSBackingValue.JSNull), nil) }

        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Unable to parse 'null' literal. Context: '\(contextualString(generator))'."]
        return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
    }

    private static func parseHexDigit(digit: UInt8) -> Int? {
        if Token.Zero <= digit && digit <= Token.Nine {
            return Int(digit) - Int(Token.Zero)
        } else if Token.a <= digit && digit <= Token.f {
            return 10 + Int(digit) - Int(Token.a)
        } else if Token.A <= digit && digit <= Token.F {
            return 10 + Int(digit) - Int(Token.A)
        } else {
            return nil
        }
    }
    
    static func parseString<S: SequenceType where S.Generator.Element == UInt8>(generator: ReplayableGenerator<S>, quote: UInt8) -> JSParsingResult {
        var bytes = [UInt8]()

        for (idx, codeunit) in generator.enumerate() {
            switch (idx, codeunit) {
            case (0, quote): continue
            case (_, quote):
                generator.next()        // eat the quote

                bytes.append(0)
                let ptr = UnsafePointer<CChar>(bytes)
                if let string = String.fromCString(ptr) {
                    return (JSValue(string), nil)
                }
                else {
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unable to convert the parsed bytes into a string. Bytes: \(bytes)'."]
                    return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }

            case (_, Token.Backslash):
                let next = generator.next()

                if let next = next {
                    switch next {

                    case Token.Backslash:
                        bytes.append(Token.Backslash)
                        
                    case Token.Forwardslash:
                        bytes.append(Token.Forwardslash)
                        
                    case quote:
                        bytes.append(Token.DoubleQuote)

                    case Token.n:
                        bytes.append(Token.Linefeed)

                    case Token.b:
                        bytes.append(Token.Backspace)

                    case Token.f:
                        bytes.append(Token.Formfeed)

                    case Token.r:
                        bytes.append(Token.CarriageReturn)

                    case Token.t:
                        bytes.append(Token.HorizontalTab)

                    case Token.u:
                        let c1 = generator.next()
                        let c2 = generator.next()
                        let c3 = generator.next()
                        let c4 = generator.next()
                        
                        switch (c1, c2, c3, c4) {
                            case let (.Some(c1), .Some(c2), .Some(c3), .Some(c4)):
                                let value1 = parseHexDigit(c1)
                                let value2 = parseHexDigit(c2)
                                let value3 = parseHexDigit(c3)
                                let value4 = parseHexDigit(c4)
                                
                                if value1 == nil || value2 == nil || value3 == nil || value4 == nil {
                                    let info = [
                                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                                        ErrorKeys.LocalizedFailureReason: "Invalid unicode escape sequence"]
                                    return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                                }

                                let codepoint = (value1! << 12) | (value2! << 8) | (value3! << 4) | value4!;
                                let character = String(UnicodeScalar(codepoint))
                                let data = character.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
                                let ptr = UnsafePointer<UInt8>(data.bytes)
                                let escapeBytes = UnsafeBufferPointer<UInt8>(start: ptr, count: data.length)
                                bytes.appendContentsOf(escapeBytes)

                            default:
                                let info = [
                                    ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                                    ErrorKeys.LocalizedFailureReason: "Invalid unicode escape sequence"]
                                return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))

                        }

                    default:
                        let info = [
                            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                            ErrorKeys.LocalizedFailureReason: "Unexpected token at index: \(idx + 1). Token: \(next). Context: '\(contextualString(generator))'."]
                        return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                    }
                }
                else {
                    let info = [
                        ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
                        ErrorKeys.LocalizedFailureReason: "Unexpected token at index: \(idx). Token: \(codeunit). Context: '\(contextualString(generator))'."]
                    return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
                }

            default:
                bytes.append(codeunit)
            }
        }

        let info = [
            ErrorKeys.LocalizedDescription: ErrorCode.ParsingError.message,
            ErrorKeys.LocalizedFailureReason: "Unable to parse string. Context: '\(contextualString(generator))'."]
        return (nil, Error(code: ErrorCode.ParsingError.code, domain: JSValueErrorDomain, userInfo: info))
    }
    

    // MARK: Helper functions

    static func substring<S: SequenceType where S.Generator.Element == UInt8>(generator: ReplayableGenerator<S>) -> String {
        var string = ""

        for codeunit in generator {
            string += String(codeunit)
        }
        
        return string
    }


    static func contextualString<S: SequenceType where S.Generator.Element == UInt8>(generator: ReplayableGenerator<S>, left: Int = 5, right: Int = 10) -> String {
        var string = ""

        for var i = left; i > 0; i-- {
            generator.replay()
        }

        for var i = 0; i < (left + right); i++ {
            let codeunit = generator.next() ?? 0
            string += String(codeunit)
        }
        
        return string
    }
    
    static func exp(number: Double, _ exp: Int) -> Double {
        return exp < 0 ?
            (0 ..< abs(exp)).reduce(number, combine: { x, _ in x / 10 }) :
            (0 ..< exp).reduce(number, combine: { x, _ in x * 10 })
    }
}

extension UInt8 {
    
    /// Determines if the `UnicodeScalar` represents one of the standard Unicode whitespace characters.
    ///
    /// :return: `true` if the scalar is a Unicode whitespace character; `false` otherwise.
    func isWhitespace() -> Bool {
        if self >= 0x09 && self <= 0x0D        { return true }     // White_Space # Cc   [5] <control-0009>..<control-000D>
        if self == 0x20                        { return true }     // White_Space # Zs       SPACE
        if self == 0x85                        { return true }     // White_Space # Cc       <control-0085>
        if self == 0xA0                        { return true }     // White_Space # Zs       NO-BREAK SPACE

        // TODO: These are no longer possible to be hit... does it matter???
//        if self == 0x1680                      { return true }     // White_Space # Zs       OGHAM SPACE MARK
//        if self >= 0x2000 && self <= 0x200A    { return true }     // White_Space # Zs  [11] EN QUAD..HAIR SPACE
//        if self == 0x2028                      { return true }     // White_Space # Zl       LINE SEPARATOR
//        if self == 0x2029                      { return true }     // White_Space # Zp       PARAGRAPH SEPARATOR
//        if self == 0x202F                      { return true }     // White_Space # Zs       NARROW NO-BREAK SPACE
//        if self == 0x205F                      { return true }     // White_Space # Zs       MEDIUM MATHEMATICAL SPACE
//        if self == 0x3000                      { return true }     // White_Space # Zs       IDEOGRAPHIC SPACE

        return false
    }
    
    /// Determines if the `UnicodeScalar` respresents a numeric digit.
    ///
    /// :return: `true` if the scalar is a Unicode numeric character; `false` otherwise.
    func isDigit() -> Bool {
        return self >= Token.Zero && self <= Token.Nine
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

//    /// Stores the `UInt8` bytes that make up the UTF8 code points for the scalar.
//    ///
//    /// :param: buffer the buffer to write the UTF8 code points into.
//    func utf8(inout buffer: [UInt8]) {
//        /*
//         *  This implementation should probably be replaced by the function below. However,
//         *  I am not quite sure how to properly use `SinkType` yet...
//         *
//         *  UTF8.encode(input: UnicodeScalar, output: &S)
//         */
//
//        if value <= 0x007F {
//            buffer.append(UInt8(value))
//        }
//        else if 0x0080 <= value && value <= 0x07FF {
//            buffer.append(UInt8(value &/ 64) &+ 192)
//            buffer.append(UInt8(value &% 64) &+ 128)
//        }
//        else if (0x0800 <= value && value <= 0xD7FF) || (0xE000 <= value && value <= 0xFFFF) {
//            buffer.append(UInt8(value &/ 4096) &+ 224)
//            buffer.append(UInt8((value &% 4096) &/ 64) &+ 128)
//            buffer.append(UInt8(value &% 64 &+ 128))
//        }
//        else {
//            buffer.append(UInt8(value &/ 262144) &+ 240)
//            buffer.append(UInt8((value &% 262144) &/ 4096) &+ 128)
//            buffer.append(UInt8((value &% 4096) &/ 64) &+ 128)
//            buffer.append(UInt8(value &% 64) &+ 128)
//        }
//    }
}

/// The code unit value for all of the token characters used.
struct Token {
    private init() {}
    
    // Control Codes
    static let Linefeed         = UInt8(10)
    static let Backspace        = UInt8(8)
    static let Formfeed         = UInt8(12)
    static let CarriageReturn   = UInt8(13)
    static let HorizontalTab    = UInt8(9)
    
    // Tokens for JSON
    static let LeftBracket      = UInt8(91)
    static let RightBracket     = UInt8(93)
    static let LeftCurly        = UInt8(123)
    static let RightCurly       = UInt8(125)
    static let Comma            = UInt8(44)
    static let SingleQuote      = UInt8(39)
    static let DoubleQuote      = UInt8(34)
    static let Minus            = UInt8(45)
    static let Plus             = UInt8(43)
    static let Backslash        = UInt8(92)
    static let Forwardslash     = UInt8(47)
    static let Colon            = UInt8(58)
    static let Period           = UInt8(46)
    
    // Numbers
    static let Zero             = UInt8(48)
    static let One              = UInt8(49)
    static let Two              = UInt8(50)
    static let Three            = UInt8(51)
    static let Four             = UInt8(52)
    static let Five             = UInt8(53)
    static let Six              = UInt8(54)
    static let Seven            = UInt8(55)
    static let Eight            = UInt8(56)
    static let Nine             = UInt8(57)
    
    // Character tokens for JSON
    static let A                = UInt8(65)
    static let E                = UInt8(69)
    static let F                = UInt8(70)
    static let a                = UInt8(97)
    static let b                = UInt8(98)
    static let e                = UInt8(101)
    static let f                = UInt8(102)
    static let l                = UInt8(108)
    static let n                = UInt8(110)
    static let r                = UInt8(114)
    static let s                = UInt8(115)
    static let t                = UInt8(116)
    static let u                = UInt8(117)
}
