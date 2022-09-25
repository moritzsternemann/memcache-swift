import ExtrasBase64
import NIOCore

extension MemcacheBackendMessage {
    struct Value: MemcacheMessagePayloadDecodable {
        var flags: Flags
        var data: ByteBuffer

        /// Decode a `VA` backend message.
        ///
        /// The message can have the following formats:
        /// - `<size> <flags>\r\n<data block>\r\n`. Flags are space-separated strings.
        /// - `<size>\r\n<data block>\r\n`
        static func decode(from buffer: inout ByteBuffer) throws -> Self {
            // Decode the size of the data block, optional flags, and the data block itself
            guard let valueMetaSlice = buffer.getCarriageReturnNewlineTerminatedSlice(at: buffer.readerIndex) else {
                // No \r\n? Something went terribly wrong...
                preconditionFailure("Expected to only see messages that contain \r\n here.")
            }

            // The size value in valueMetaSlice is either the entire slice or the part before the first <space>
            let endSizeIndex = valueMetaSlice.readableBytesView.firstIndex(of: .space) ?? valueMetaSlice.writerIndex

            guard let sizeString = valueMetaSlice.getString(at: valueMetaSlice.readerIndex, length: endSizeIndex) else {
                preconditionFailure("We have readable bytes so we should be able to read a string")
            }

            guard let size = Int(sizeString) else {
                throw MemcachePartialDecodingError.fieldNotDecodable(as: Int.self, from: sizeString)
            }

            // Move the buffer's readerIndex to after the size so we can continue reading flags and/or data.
            buffer.moveReaderIndex(forwardBy: endSizeIndex)

            if buffer.readableBytesView.first == .space {
                // Move the reader index to after the <space> that is following the size
                buffer.moveReaderIndex(forwardBy: 1)
            }

            let flags = try Flags.decode(from: &buffer)

            guard let dataBlock = buffer.readSlice(length: size) else {
                // Tell the decoder that we expect more data
                throw MemcacheNeedMoreDataError()
            }

            // Make sure we received the final terminating \r\n.
            guard let _ = buffer.readCarriageReturnNewlineTerminatedSlice() else {
                throw MemcacheNeedMoreDataError()
            }

            return Value(flags: flags, data: dataBlock)
        }
    }
}

extension MemcacheBackendMessage.Value: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(flags), data: \(String(base64Encoding: data.readableBytesView))"
    }
}
