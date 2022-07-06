//
//  MemcacheMessageEncoder.swift
//  
//
//  Created by Moritz Sternemann on 27.06.22.
//

import NIOCore

final class MemcacheMessageEncoder: MessageToByteEncoder {
    typealias OutboundIn = MemcacheCommandPayload

    init() {}

    func encode(data payload: MemcacheCommandPayload, out: inout ByteBuffer) throws {
        let commandString = ([payload.keyword] + payload.arguments)
            .joined(separator: " ") + "\r\n"
        out.writeString(commandString)
        
        if var data = payload.data {
            out.writeBuffer(&data)
            out.writeStaticString("\r\n")
        }
    }
}
