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
