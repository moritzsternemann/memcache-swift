import NIOCore

extension MemcacheBackendMessage {
    struct ErrorMessage: MemcacheMessagePayloadDecodable, ExpressibleByStringLiteral {
        let message: String

        init(stringLiteral value: String) {
            self.message = value
        }

        static func decode(from buffer: inout ByteBuffer) throws -> Self {
            // An error message is always the last part of a text line, which is terminated by \r\n.
            guard var messageSlice = buffer.readCarriageReturnNewlineTerminatedSlice() else {
                preconditionFailure("Expected to only see messages that contain \r\n here.")
            }

            guard messageSlice.readableBytes > 0 else {
                throw MemcachePartialDecodingError.expectedAtLeastNRemainingCharacters(1, actual: messageSlice.readableBytes)
            }

            let messageString = messageSlice.readString(length: messageSlice.readableBytes)!

            return ErrorMessage(stringLiteral: messageString)
        }
    }
}

extension MemcacheBackendMessage.ErrorMessage: CustomDebugStringConvertible {
    var debugDescription: String {
        "message: \"\(message)\""
    }
}
