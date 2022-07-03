//
//  MemcacheCommand.swift
//  
//
//  Created by Moritz Sternemann on 04.06.22.
//

import NIO

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
