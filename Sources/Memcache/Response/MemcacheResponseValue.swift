//
//  MemcacheResponseValue.swift
//  
//
//  Created by Moritz Sternemann on 03.07.22.
//

import NIOCore

public struct MemcacheResponseValue {
    let key: MemcacheKey
    let data: ByteBuffer
    let flags: UInt16
    let bytes: UInt // TODO: Remove?
    let casUnique: UInt64?
}

// MARK: MemcacheResponseValueConvertible

extension MemcacheResponseValue: MemcacheResponseValueConvertible {
    public init?(fromResponseValue value: MemcacheResponseValue) {
        self = value
    }
}

// MARK: MemcacheResponseValue Conversion

extension MemcacheResponseValue {
    func map<Value: MemcacheResponseValueConvertible>(to type: Value.Type = Value.self) throws -> Value {
        guard let value = Value(fromResponseValue: self) else { fatalError() }
        return value
    }
}
