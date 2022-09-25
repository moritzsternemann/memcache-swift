@testable import Memcache

extension MemcacheBackendMessage: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.header(lhs), .header(rhs)):
            return lhs == rhs
        case let (.notFound(lhs), .notFound(rhs)):
            return lhs == rhs
        case let (.notStored(lhs), .notStored(rhs)):
            return lhs == rhs
        case let (.exists(lhs), .exists(rhs)):
            return lhs == rhs
        case let (.value(lhs), .value(rhs)):
            return lhs == rhs
        case (.end, .end):
            return true
        default:
            return false
        }
    }
}

extension MemcacheBackendMessage.Value: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.flags == rhs.flags && lhs.data == rhs.data
    }
}

extension MemcacheBackendMessage.Flags: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.flags == rhs.flags
    }
}

extension MemcacheFlag: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.b, .b), (.c, .c), (.k, .k), (.q, .q), (.v, .v), (.t, .t), (.I, .I), (.f, .f), (.h, .h), (.l, .l), (.s, .s), (.u, .u), (.W, .W), (.X, .X), (.Z, .Z):
            return true
        case let (.P(lhs), .P(rhs)), let (.L(lhs), .L(rhs)):
            return lhs == rhs
        case let (.F(lhs), .F(rhs)):
            return lhs == rhs
        case let (.C(lhs), .C(rhs)), let (.J(lhs), .J(rhs)), let (.D(lhs), .D(rhs)):
            return lhs == rhs
        case let (.O(lhs), .O(rhs)):
            return lhs == rhs
        case let (.T(lhs), .T(rhs)), let (.N(lhs), .N(rhs)), let (.R(lhs), .R(rhs)):
            return lhs == rhs
        case let (.M(lhs), .M(rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension MemcacheFlag.StringToken: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}

extension MemcacheFlag.NumericToken: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}

extension MemcacheFlag.OpaqueToken: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}

extension MemcacheFlag.TTLToken: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}
