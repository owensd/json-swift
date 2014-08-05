
/// A `Failable` should be returned from functions that need to return success or failure information but has no other
/// meaning information to return. Functions that need to also return a value on success should use `FailableOf<T>`.
public enum Failable {
    case Success
    case Failure(Error)

    init() {
        self = .Success
    }

    init(_ error: Error) {
        self = .Failure(error)
    }

    public var failed: Bool {
        switch self {
        case .Failure(let error):
            return true

        default:
            return false
        }
    }

    public var error: Error? {
        switch self {
        case .Failure(let error):
            return error

        default:
            return nil
        }
    }
}

/// A `FailableOf<T>` should be returned from functions that need to return success or failure information and some
/// corresponding data back upon a successful function call.
public enum FailableOf<T> {
    case Success(FailableValueWrapper<T>)
    case Failure(Error)

    public init(_ value: T) {
        self = .Success(FailableValueWrapper(value))
    }

    public init(_ error: Error) {
        self = .Failure(error)
    }

    public var failed: Bool {
        switch self {
        case .Failure(let error):
            return true

        default:
            return false
        }
    }

    public var error: Error? {
        switch self {
        case .Failure(let error):
            return error

        default:
            return nil
        }
    }

    public var value: T? {
        switch self {
        case .Success(let wrapper):
            return wrapper.value

        default:
            return nil
        }
    }
}

/// This is a workaround-wrapper class for a bug in the Swift compiler. DO NOT USE THIS CLASS!!
public class FailableValueWrapper<T> {
    public let value: T
    public init(_ value: T) { self.value = value }
}

