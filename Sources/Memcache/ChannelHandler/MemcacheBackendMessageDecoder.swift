import Foundation
import NIOCore

struct MemcacheBackendMessageDecoder: NIOSingleStepByteToMessageDecoder {
    typealias InboundOut = MemcacheBackendMessage

    func decode(buffer: inout ByteBuffer) throws -> MemcacheBackendMessage? {
        // Keep track of the reader index in case we later notice that we need more data
        let startReaderIndex = buffer.readerIndex

        // Peek at the message to read the verb. It is before the first \r\n and before the first <space> if the message
        // contains one.
        guard let messageSlice = buffer.getCarriageReturnNewlineTerminatedSlice(at: buffer.readerIndex) else {
            // reader index wasn't moved, wait for more bytes
            return nil
        }

        // The verb in messageSlice is either the entire slice or the part before the first <space>
        let endVerbIndex = messageSlice.readableBytesView.firstIndex(of: .space) ?? messageSlice.writerIndex

        guard let verbString = messageSlice.getString(at: messageSlice.readerIndex, length: endVerbIndex) else {
            // If we can't read a string, the messageSlice must be empty (i.e. no characters before the first occurence of \r\n)
            throw MemcacheDecodingError.emptyMessageReceived(bytes: buffer)
        }

        guard let verb = MemcacheBackendMessage.Verb(rawValue: verbString) else {
            throw MemcacheDecodingError.unknownVerbReceived(messageVerb: verbString, messageBytes: messageSlice)
        }

        // Move the buffer's readerIndex to after the verb so we can continue reading flags and/or data.
        buffer.moveReaderIndex(forwardBy: endVerbIndex)

        if buffer.readableBytesView.first == .space {
            // Move the reader index to after the <space> that is following the verb
            buffer.moveReaderIndex(forwardBy: 1)
        }

        do {
            // Pass the buffer instead of messageSlice because .value messages continue after the first \r\n
            let result = try MemcacheBackendMessage.decode(from: &buffer, for: verb)
            // TODO: Can we make sure the message was read entirely? Difficult because we don't know the length of VA messages here.
            return result
        } catch _ as MemcacheNeedMoreDataError {
            // A message decoder told us that it expects more data. Move the reader index back to the start and try again.
            buffer.moveReaderIndex(to: startReaderIndex)
            return nil
        } catch let error as MemcachePartialDecodingError {
            throw MemcacheDecodingError.withPartialError(error, messageVerb: verb.rawValue, messageBytes: messageSlice)
        } catch {
            preconditionFailure("Expected to only see `MemcachePartialDecodingError` here.")
        }
    }

    func decodeLast(buffer: inout ByteBuffer, seenEOF: Bool) throws -> MemcacheBackendMessage? {
        try self.decode(buffer: &buffer)
    }
}
