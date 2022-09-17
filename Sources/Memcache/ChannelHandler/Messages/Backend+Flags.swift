import NIOCore

extension MemcacheBackendMessage {
    struct Flags: MemcacheMessagePayloadDecodable, Equatable, ExpressibleByArrayLiteral {
        let flags: [String]

        init(_ flags: [String]) {
            self.flags = flags
        }

        init(arrayLiteral elements: String...) {
            flags = elements
        }

        static func decode(from buffer: inout ByteBuffer) throws -> Self {
            guard buffer.readableBytes > 2 else { return [] }

            let bytes = buffer.readableBytesView
            guard let newlineIndex = bytes.firstIndex(of: .newline),
                  bytes[newlineIndex - 1] == .carriageReturn,
                  let flagsString = buffer.getString(at: buffer.readerIndex, length: newlineIndex - 2 - buffer.readerIndex)
            else {
                fatalError() // TODO:  invalid string error
            }

            // we read the flags but not the tailing \r\n
            buffer.moveReaderIndex(to: newlineIndex - 1)

            return Flags(flagsString.components(separatedBy: " "))
        }
    }
}

extension MemcacheBackendMessage.Flags: CustomDebugStringConvertible {
    var debugDescription: String {
        "[\(flags.map({ "\"\($0)\"" }).joined(separator: ", "))]"
    }
}
