//
//  MemcacheMetaCommand.swift
//  
//
//  Created by Moritz Sternemann on 04.06.22.
//

import NIOCore

public struct MemcacheMetaCommandPayload {
    public let command: [String]
    public let data: ByteBuffer?
}

public struct MemcacheMetaCommand<Flag: MemcacheMetaFlag> {
    public let payload: MemcacheMetaCommandPayload

    public init(
        commandCode: String,
        key: MemcacheKey,
        flags: Set<Flag> = [],
        data: ByteBuffer? = nil
    ) {
        var command: [String] = [commandCode, key.rawValue]
        if let data = data {
            command.append("\(data.readableBytes)")
        }
        command.append(contentsOf: flags.map(\.stringValue))

        self.payload = .init(command: command, data: data)
    }
}
