//
//  MemcacheMetaFlag.swift
//  
//
//  Created by Moritz Sternemann on 16.08.22.
//

public protocol MemcacheMetaFlag: Hashable {
    var stringValue: String { get }
    init(stringValue: String) throws
}

extension MemcacheMetaFlag {
    static func map(_ flags: Set<String>) throws -> Set<Self> {
        Set(try flags.map { try Self(stringValue: $0) })
    }
}

// MARK: - Get

public enum MemcacheMetaGetFlag: MemcacheMetaFlag {
//    - b: interpret key as base64 encoded binary value
//    - c: return item cas token
//    - f: return client flags token
//    - h: return whether item has been hit before as a 0 or 1
//    - k: return key as a token
//    - l: return time since item was last accessed in seconds
//    - O(token): opaque value, consumes a token and copies back with response
//    - q: use noreply semantics for return codes.
//    - s: return item size token
//    - t: return item TTL remaining in seconds (-1 for unlimited)
//    - u: don't bump the item in the LRU
//    - v: return item value in <data block>
//    - N(token): vivify on miss, takes TTL as a argument
//    - R(token): if token is less than remaining TTL win for recache
//    - T(token): update remaining TTL
//    - W: client has "won" the recache flag
//    - X: item is stale
//    - Z: item has already sent a winning flag
    case binaryKey
    case value

    public var stringValue: String {
        switch self {
        case .binaryKey: return "b"
        case .value: return "v"
        }
    }

    public init(stringValue: String) throws {
        switch stringValue.first {
        case "b": self = .binaryKey
        case "v": self = .value
        default: fatalError() // TODO: unknown or empty flag error (maybe crash)
        }
    }
}

public typealias MemcacheMetaGetFlags = Set<MemcacheMetaGetFlag>

// MARK: - Set

public enum MemcacheMetaSetFlag: MemcacheMetaFlag {
//    - b: interpret key as base64 encoded binary value (see metaget)
//    - c: return CAS value if successfully stored.
//    - C(token): compare CAS value when storing item
//    - F(token): set client flags to token (32 bit unsigned numeric)
//    - I: invalidate. set-to-invalid if supplied CAS is older than item's CAS
//    - k: return key as a token
//    - O(token): opaque value, consumes a token and copies back with response
//    - q: use noreply semantics for return codes
//    - T(token): Time-To-Live for item, see "Expiration" above.
//    - M(token): mode switch to change behavior to add, replace, append, prepend
    case binaryKey
    case ttl(String)

    public var stringValue: String {
        switch self {
        case .binaryKey: return "b"
        case .ttl(let token): return "T\(token)"
        }
    }

    public init(stringValue: String) throws {
        switch stringValue.first {
        case "b": self = .binaryKey
        case "T": self = .ttl(String(stringValue.dropFirst()))
        default: fatalError() // TODO: unknown or empty flag error (maybe crash)
        }
    }
}

public typealias MemcacheMetaSetFlags = Set<MemcacheMetaSetFlag>

// MARK: - Delete

public enum MemcacheMetaDeleteFlag: MemcacheMetaFlag {
//    - b: interpret key as base64 encoded binary value (see metaget)
//    - C(token): compare CAS value
//    - I: invalidate. mark as stale, bumps CAS.
//    - k: return key
//    - O(token): opaque to copy back.
//    - q: noreply
//    - T(token): updates TTL, only when paired with the 'I' flag
    case binaryKey

    public var stringValue: String {
        fatalError()
    }

    public init(stringValue: String) throws {
        fatalError()
    }
}

public typealias MemcacheMetaDeleteFlags = Set<MemcacheMetaDeleteFlag>

// MARK: - Arithmetic

public enum MemcacheMetaArithmeticFlag: MemcacheMetaFlag {
//    - b: interpret key as base64 encoded binary value (see metaget)
//    - C(token): compare CAS value (see mset)
//    - N(token): auto create item on miss with supplied TTL
//    - J(token): initial value to use if auto created after miss (default 0)
//    - D(token): delta to apply (decimal unsigned 64-bit number, default 1)
//    - T(token): update TTL on success
//    - M(token): mode switch to change between incr and decr modes.
//    - q: use noreply semantics for return codes (see details under mset)
//    - t: return current TTL
//    - c: return current CAS value if successful.
//    - v: return new value
    case binaryKey

    public var stringValue: String {
        fatalError()
    }

    public init(stringValue: String) throws {
        fatalError()
    }
}

public typealias MemcacheMetaArithmeticFlags = Set<MemcacheMetaArithmeticFlag>
