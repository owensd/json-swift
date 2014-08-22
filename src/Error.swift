/// Creates a new type that is used to represent error information in Swift.
///
/// This is a new Swift-specific error type used to return error information. The primary usage of this object is to
/// return it as a `Failable` or `FailableOf<T>` from function that could fail.
///
/// Example:
///   `func readContentsOfFileAtPath(path: String) -> Failable<String>`
///
public final class Error {
    public typealias ErrorInfoDictionary = [String:String]

    /// The error code used to differentiate between various error states.
    public let code: Int

    /// A string that is used to group errors into related error buckets.
    public let domain: String

    /// A place to store any custom information that needs to be passed along with the error instance.
    public let userInfo: ErrorInfoDictionary

    /// Initializes a new `Error` instance.
    public init(code: Int, domain: String, userInfo: ErrorInfoDictionary?) {
        self.code = code
        self.domain = domain
        if let info = userInfo {
            self.userInfo = info
        }
        else {
            self.userInfo = ErrorInfoDictionary()
        }
    }

    /// A single, representative instance of an 'Empty' `Error` object.
    //public static let Empty = Error(code: 0, domain: "", userInfo: nil)
}

/// The standard keys used in `Error` and `userInfo`.
public struct ErrorKeys {
    private init() {}
    
    public static let LocalizedDescription                   = "NSLocalizedDescription"
    public static let LocalizedFailureReason                 = "NSLoclalizedFailureReason"
    public static let LocalizedRecoverySuggestion            = "NSLocalizedRecoverySuggestion"
    public static let LocalizedRecoveryOptions               = "NSLocalizedRecoveryOptions"
    public static let RecoveryAttempter                      = "NSRecoveryAttempter"
    public static let HelpAnchor                             = "NSHelpAnchor"
    
    public static let StringEncoding                         = "NSStringEncoding"
    public static let URL                                    = "NSURL"
    public static let FilePath                               = "NSFilePath"
}


extension Error {
    
//    /// An initializer that is to be used within your own applications and libraries to hide any of the
//    /// ObjC interfaces from your purely Swift APIs.
//    public convenience init(_ error: NSErrorPointer) {
//        if let memory = error.memory {
//            self.code = memory.code
//            self.domain = memory.domain
//            
//            // TODO: Only supports pulling out one key at the moment, more will come later...
//            if let info = memory.userInfo {
//                self.userInfo = ErrorInfoDictionary()
//                if let localizedDescription = info[NSLocalizedDescriptionKey] as? NSString {
//                    self.userInfo[ErrorKeys.LocalizedDescription] = localizedDescription
//                }
//            }
//            else {
//                self.userInfo = ErrorInfoDictionary()
//            }
//        }
//        else {
//            self.code = 0
//            self.domain = ""
//            self.userInfo = ErrorInfoDictionary()
//        }
//    }
}

extension Error: Printable {
    public var description: String {
        return "an error..."
    }
}