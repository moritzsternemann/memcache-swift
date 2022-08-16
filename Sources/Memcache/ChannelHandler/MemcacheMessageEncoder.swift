//
//  MemcacheMessageEncoder.swift
//  
//
//  Created by Moritz Sternemann on 27.06.22.
//

import NIOCore

struct BufferedMessageEncoder {
    private enum State {
        case flushed
        case writable
    }

    private var buffer: ByteBuffer
    private var state: State = .writable
    private var encoder: MemcacheMessageEncoder

    init(buffer: ByteBuffer, encoder: MemcacheMessageEncoder) {
        self.buffer = buffer
        self.encoder = encoder
    }

    mutating func encode(_ message: MemcacheMetaCommandPayload) {
        switch state {
        case .flushed:
            state = .writable
            buffer.clear()
        case .writable:
            break
        }

        encoder.encode(data: message, out: &buffer)
    }

    mutating func flush() -> ByteBuffer {
        state = .flushed
        return buffer
    }
}

struct MemcacheMessageEncoder: MessageToByteEncoder {
    typealias OutboundIn = MemcacheMetaCommandPayload

    init() {}

    func encode(data payload: MemcacheMetaCommandPayload, out: inout ByteBuffer) {
        let commandString = payload.command.joined(separator: " ") + "\r\n"
        out.writeString(commandString)
        
        if var data = payload.data {
            out.writeBuffer(&data)
            out.writeStaticString("\r\n")
        }
    }
}
