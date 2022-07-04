//
//  MemcacheExpiration.swift
//  
//
//  Created by Moritz Sternemann on 27.06.22.
//

public enum MemcacheExpiration: RawRepresentable {
    //
    case absolute(UInt)
    case relative(UInt)

    public var rawValue: UInt {
        switch self {
        case let .relative(seconds),
            let .absolute(seconds):
            return seconds
        }
    }

    public init?(rawValue: UInt) {
        self.init(rawValue)
    }

    public init(_ seconds: UInt) {
        if seconds > 60 * 60 * 24 * 30 {
            self = .absolute(seconds)
        } else {
            self = .relative(seconds)
        }
    }
}
