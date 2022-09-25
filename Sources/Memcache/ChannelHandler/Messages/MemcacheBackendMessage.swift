import NIOCore

protocol MemcacheMessagePayloadDecodable {
    static func decode(from buffer: inout ByteBuffer) throws -> Self
}

enum MemcacheBackendMessage {
    /// Header (`HD <flags>*\r\n`)
    case header(Flags)

    /// Not found (`NF <flags>*\r\n`)
    case notFound(Flags)

    /// Not stored (`NS <flags>*\r\n`)
    case notStored(Flags)

    /// Exists (`EX <flags>*\r\n`)
    case exists(Flags)

    /// Value (`VA <size> <flags>*\r\n<data block>\r\n`)
    case value(Value)

    /// End (`EN\r\n`)
    case end

    /// Nonexistent command name (`ERROR\r\n`)
    case nonExistentCommandError

    /// Client error (`CLIENT_ERROR <error>\r\n`)
    case clientError(ErrorMessage)

    /// Server error (`SERVER_ERROR <error>\r\n`)
    case serverError(ErrorMessage)
}

extension MemcacheBackendMessage {
    enum Verb: RawRepresentable {
        typealias RawValue = String

        case header
        case notFound
        case notStored
        case exists
        case value
        case end

        case nonExistentCommandError
        case clientError
        case serverError

        init?(rawValue: String) {
            switch rawValue {
            case "HD":
                self = .header
            case "NF":
                self = .notFound
            case "NS":
                self = .notStored
            case "EX":
                self = .exists
            case "VA":
                self = .value
            case "EN":
                self = .end
            case "ERROR":
                self = .nonExistentCommandError
            case "CLIENT_ERROR":
                self = .clientError
            case "SERVER_ERROR":
                self = .serverError
            default:
                return nil
            }
        }

        var rawValue: String {
            switch self {
            case .header:
                return "HD"
            case .notFound:
                return "NF"
            case .notStored:
                return "NS"
            case .exists:
                return "EX"
            case .value:
                return "VA"
            case .end:
                return "EN"
            case .nonExistentCommandError:
                return "ERROR"
            case .clientError:
                return "CLIENT_ERROR"
            case .serverError:
                return "SERVER_ERROR"
            }
        }
    }
}

extension MemcacheBackendMessage {
    static func decode(from buffer: inout ByteBuffer, for verb: Verb) throws -> MemcacheBackendMessage {
        switch verb {
        case .header:
            return try .header(.decode(from: &buffer))
        case .notFound:
            return try .notFound(.decode(from: &buffer))
        case .notStored:
            return try .notStored(.decode(from: &buffer))
        case .exists:
            return try .exists(.decode(from: &buffer))
        case .value:
            return try .value(.decode(from: &buffer))
        case .end:
            buffer.moveReaderIndex(forwardBy: 2)
            return .end
        case .nonExistentCommandError:
            buffer.moveReaderIndex(forwardBy: 2)
            return .nonExistentCommandError
        case .clientError:
            return try .clientError(.decode(from: &buffer))
        case .serverError:
            return try .serverError(.decode(from: &buffer))
        }
    }
}

extension MemcacheBackendMessage: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case let .header(flags):
            return ".header(\(String(reflecting: flags)))"
        case let .notFound(flags):
            return ".notFound(\(String(reflecting: flags)))"
        case let .notStored(flags):
            return ".notStored(\(String(reflecting: flags)))"
        case let .exists(flags):
            return ".exists(\(String(reflecting: flags)))"
        case let .value(value):
            return ".value(\(String(reflecting: value)))"
        case .end:
            return ".end"
        case .nonExistentCommandError:
            return ".nonExistentCommandError"
        case let .clientError(string):
            fatalError(string)
        case let .serverError(string):
            fatalError(string)
        }
    }
}
