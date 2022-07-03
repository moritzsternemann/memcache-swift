//
//  MemcacheKey.swift
//  
//
//  Created by Moritz Sternemann on 27.06.22.
//

public struct MemcacheKey: RawRepresentable {
    public let rawValue: String

    public init(_ key: String) {
        self.rawValue = key
    }

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension MemcacheKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

extension MemcacheKey: ExpressibleByStringInterpolation {}

extension MemcacheKey: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension MemcacheKey: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(String(describing: type(of: self))): \(rawValue)"
    }
}

extension MemcacheKey: Comparable {
    public static func <(lhs: MemcacheKey, rhs: MemcacheKey) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension MemcacheKey: Hashable {}

extension MemcacheKey: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
