extension MemcacheFlag {
    /// A string token without any constraints.
    struct StringToken: ExpressibleByStringLiteral, CustomDebugStringConvertible {
        var value: String

        init(stringLiteral value: String) {
            self.value = value
        }

        var debugDescription: String {
            "string: \(value)"
        }
    }

    /// A numeric token.
    struct NumericToken<Value: Numeric>: CustomDebugStringConvertible {
        var value: Value

        var debugDescription: String {
            "numeric: \(value)"
        }
    }

    /// Opaque tokens may be up to 32 bytes in length.
    struct OpaqueToken: ExpressibleByStringLiteral, CustomDebugStringConvertible {
        var value: String

        init(stringLiteral value: StringLiteralType) {
            self.value = value
        }

        var debugDescription: String {
            "opaque: \(value)"
        }
    }

    /// A numeric token representing a TTL value.
    struct TTLToken: ExpressibleByIntegerLiteral, CustomDebugStringConvertible {
        let value: UInt32

        init(integerLiteral value: UInt32) {
            self.value = value
        }

        var debugDescription: String {
            "ttl: \(value)"
        }
    }

    /// Mode switch token used in Set and Arithmetic commands.
    enum ModeToken: RawRepresentable, CustomDebugStringConvertible {
        typealias RawValue = Character

        // MARK: 'Set'-modes

        case add
        case append
        case prepend
        case replace
        case set

        // MARK: 'Arithmetic'-modes

        case increment
        case decrement

        init?(rawValue: Character) {
            switch rawValue {
            case "E":
                self = .add
            case "A":
                self = .append
            case "P":
                self = .prepend
            case "R":
                self = .replace
            case "S":
                self = .set
            case "I", "+":
                self = .increment
            case "D", "-":
                self = .decrement
            default:
                return nil
            }
        }

        var rawValue: Character {
            switch self {
            case .add:
                return "E"
            case .append:
                return "A"
            case .prepend:
                return "P"
            case .replace:
                return "R"
            case .set:
                return "S"
            case .increment:
                return "I"
            case .decrement:
                return "D"
            }
        }

        var debugDescription: String {
            switch self {
            case .add:
                return ".add"
            case .append:
                return ".append"
            case .prepend:
                return ".prepend"
            case .replace:
                return ".replace"
            case .set:
                return ".set"
            case .increment:
                return ".increment"
            case .decrement:
                return ".decrement"
            }
        }
    }
}
