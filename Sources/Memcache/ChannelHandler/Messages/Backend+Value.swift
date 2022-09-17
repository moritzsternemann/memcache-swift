import NIOCore

extension MemcacheBackendMessage {
    struct Value: MemcacheMessagePayloadDecodable, Equatable {
        var flags: Flags
        var data: ByteBuffer

        static func decode(from buffer: inout ByteBuffer) throws -> Self {
            let bytes = buffer.readableBytesView

            let nextSpaceIndex = bytes.firstIndex(of: .space)
            let nextNewlineIndex = bytes.firstIndex(of: .newline)
            let sizeStringEndIndex: Int
            if let nextSpaceIndex = nextSpaceIndex,
               let nextNewlineIndex = nextNewlineIndex,
               nextSpaceIndex < nextNewlineIndex {
                // Flags after the size string
                sizeStringEndIndex = nextSpaceIndex - 1
            } else if let nextNewlineIndex = nextNewlineIndex {
                // No flags after the size string
                sizeStringEndIndex = nextNewlineIndex - 1
            } else {
                fatalError() // TODO: unexpected message format error
            }

            guard let sizeString = buffer.readString(length: sizeStringEndIndex - bytes.startIndex),
                  let size = Int(sizeString)
            else {
                fatalError() // TODO: unexpected message format error
            }

            let flags: Flags
            if let nextSpaceIndex = nextSpaceIndex,
               let nextNewlineIndex = nextNewlineIndex,
               nextSpaceIndex < nextNewlineIndex {
                buffer.moveReaderIndex(forwardBy: 1) // <space>
                flags = try .decode(from: &buffer)
            } else {
                flags = Flags()
            }

            buffer.moveReaderIndex(forwardBy: 2) // \r\n
            guard let dataBlock = buffer.readSlice(length: size) else {
                fatalError() // TODO: Not enough data error
            }

            return Value(flags: flags, data: dataBlock)
        }
    }
}

extension MemcacheBackendMessage.Value: CustomDebugStringConvertible {
    var debugDescription: String {
        return "flags: \(flags), data: \(data.readableBytes) bytes"
    }
}
