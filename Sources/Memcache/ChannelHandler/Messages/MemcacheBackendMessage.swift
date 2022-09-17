import NIOCore

protocol MemcacheMessagePayloadDecodable {
    static func decode(from buffer: inout ByteBuffer) throws -> Self
}

enum MemcacheBackendMessage {
    case header(Flags)
    case notFound(Flags)
    case notStored(Flags)
    case exists(Flags)
    case value(Value)
    case end
    // TODO: error responses
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
        // TODO: error responses

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
            return .end
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
        }
    }
}
