//
//  MemcacheResponseValueConvertible.swift
//  
//
//  Created by Moritz Sternemann on 03.07.22.
//

public protocol MemcacheResponseConvertible {
    init?(fromResponse response: MemcacheResponse)
}

public protocol MemcacheResponseValueConvertible: MemcacheResponseConvertible {
    init?(fromResponseValue value: MemcacheResponseValue)
}

extension MemcacheResponseValueConvertible {
    public init?(fromResponse response: MemcacheResponse) {
        guard case let .values(values) = response else { return nil }
        guard let first = values.first else { return nil }
        guard let firstValue = Self(fromResponseValue: first) else { return nil }
        self = firstValue
    }
}

// MARK: String

extension String: MemcacheResponseValueConvertible {
    public init?(fromResponseValue value: MemcacheResponseValue) {
        let buffer = value.data
        guard let string =  buffer.getString(at: buffer.readerIndex, length: buffer.readableBytes) else { return nil }
        self = string
    }
}

// MARK: Collections

extension Array: MemcacheResponseConvertible where Element: MemcacheResponseValueConvertible {
    public init?(fromResponse response: MemcacheResponse) {
        guard case let .values(responseValues) = response,
              let values = try? responseValues.map({ try $0.map(to: Element.self) })
        else { return nil }
        self = values
    }
}

// MARK: Optional

extension Optional: MemcacheResponseConvertible where Wrapped: MemcacheResponseConvertible {
    public init?(fromResponse response: MemcacheResponse) {
        guard let wrapped = Wrapped(fromResponse: response) else { return nil }
        self = .some(wrapped)
    }
}

extension Optional: MemcacheResponseValueConvertible where Wrapped: MemcacheResponseValueConvertible {
    public init?(fromResponseValue value: MemcacheResponseValue) {
        guard let wrapped = Wrapped(fromResponseValue: value) else { return nil }
        self = .some(wrapped)
    }
}

// MARK: Foundation.Data

import struct Foundation.Data

extension Data: MemcacheResponseValueConvertible {
    public init?(fromResponseValue value: MemcacheResponseValue) {
        self = Data(value.data.readableBytesView)
    }
}
