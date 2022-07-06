//
//  MemcacheCommand.swift
//  
//
//  Created by Moritz Sternemann on 04.06.22.
//

import NIOCore

public struct MemcacheCommandPayload {
    public let keyword: String
    public let arguments: [String]
    public let data: ByteBuffer?
}

public struct MemcacheCommand<Result> {
    public let payload: MemcacheCommandPayload

    let transform: (MemcacheResponse) throws -> Result

    public init(
        keyword: String,
        arguments: [String],
        data: ByteBuffer? = nil,
        mapResponse transform: @escaping (MemcacheResponse) throws -> Result
    ) {
        self.payload = .init(
            keyword: keyword,
            arguments: arguments,
            data: data
        )
        self.transform = transform
    }
}

extension MemcacheCommand where Result == MemcacheResponse {
    public init(keyword: String, arguments: [String], data: ByteBuffer? = nil) {
        self.init(keyword: keyword, arguments: arguments, data: data) { $0 }
    }
}

extension MemcacheCommand where Result == MemcacheResponseValue {
    public init(keyword: String, arguments: [String], data: ByteBuffer? = nil) {
        self.init(keyword: keyword, arguments: arguments, data: data) {
            try $0.map(to: Result.self)
        }
    }
}

extension MemcacheCommand where Result: MemcacheResponseConvertible {
    public init(keyword: String, arguments: [String], data: ByteBuffer? = nil) {
        self.init(keyword: keyword, arguments: arguments, data: data) {
            try $0.map(to: Result.self)
        }
    }
}

extension MemcacheCommand where Result: MemcacheResponseValueConvertible {
    public init(keyword: String, arguments: [String], data: ByteBuffer? = nil) {
        self.init(keyword: keyword, arguments: arguments, data: data) {
            try $0.map(to: Result.self)
        }
    }
}

extension MemcacheCommand where Result == Void {
    public init(keyword: String, arguments: [String], data: ByteBuffer? = nil) {
        self.init(keyword: keyword, arguments: arguments, data: data) { _ in }
    }
}
