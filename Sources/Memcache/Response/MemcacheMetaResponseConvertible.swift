//
//  MemcacheMetaResponseConvertible.swift
//  
//
//  Created by Moritz Sternemann on 03.07.22.
//

public protocol MemcacheMetaResponseConvertible {
    init?<Flag>(fromResponse response: MemcacheMetaResponse<Flag>) // TODO: Throwing instead?
}

// MARK: String

extension String: MemcacheMetaResponseConvertible {
    public init?<Flag>(fromResponse response: MemcacheMetaResponse<Flag>) {
        guard case let .value(_, data) = response,
              let string =  data.getString(at: data.readerIndex, length: data.readableBytes)
        else { return nil }
        self = string
    }
}

// MARK: Integers

extension FixedWidthInteger {
    public init?<Flag>(fromResponse response: MemcacheMetaResponse<Flag>) {
        guard case let .value(_, data) = response,
              let integer = data.getInteger(at: data.readerIndex, as: Self.self)
        else { return nil }
        self = integer
    }
}

extension Int: MemcacheMetaResponseConvertible {}
extension Int8: MemcacheMetaResponseConvertible {}
extension Int16: MemcacheMetaResponseConvertible {}
extension Int32: MemcacheMetaResponseConvertible {}
extension Int64: MemcacheMetaResponseConvertible {}
extension UInt: MemcacheMetaResponseConvertible {}
extension UInt8: MemcacheMetaResponseConvertible {}
extension UInt16: MemcacheMetaResponseConvertible {}
extension UInt32: MemcacheMetaResponseConvertible {}
extension UInt64: MemcacheMetaResponseConvertible {}

// MARK: Double, Float

extension Double: MemcacheMetaResponseConvertible {
    public init?<Flag>(fromResponse response: MemcacheMetaResponse<Flag>) {
        fatalError()

    }
}

extension Float: MemcacheMetaResponseConvertible {
    public init?<Flag>(fromResponse response: MemcacheMetaResponse<Flag>) {
        fatalError()
    }
}

// MARK: Optional

//extension Optional: MemcacheResponseConvertible where Wrapped: MemcacheResponseConvertible {
//    public init?(fromResponse response: MemcacheResponse) {
//        guard let wrapped = Wrapped(fromResponse: response) else { return nil }
//        self = .some(wrapped)
//    }
//}
