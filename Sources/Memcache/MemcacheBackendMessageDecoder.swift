import Foundation
import NIOCore

struct MemcacheBackendMessageDecoder: NIOSingleStepByteToMessageDecoder {
    typealias InboundOut = MemcacheBackendMessage

    func decode(buffer: inout ByteBuffer) throws -> MemcacheBackendMessage? {
        // Keep a copy in case we later notice that we need more data
        var peekableBuffer = buffer

        // Peek at the message to read the verb. It is before the first \r\n and before the first <space> if the message
        // contains one.
        guard let textLine = peekableBuffer.getCarriageReturnNewlineTerminatedSlice(at: peekableBuffer.readerIndex) else {
            return nil // wait for more bytes
        }

        // The verb is either the entire text line or the part before the first <space>
        let verbLength = (textLine.readableBytesView.firstIndex(of: .space) ?? textLine.writerIndex) - textLine.readerIndex

        guard let verbString = textLine.getString(at: textLine.readerIndex, length: verbLength) else {
            // If we can't read a string, the text line must be empty (i.e. no characters before the first occurence of \r\n)
            throw MemcacheDecodingError.emptyMessageReceived(bytes: peekableBuffer)
        }

        guard let verb = MemcacheBackendMessage.Verb(rawValue: verbString) else {
            throw MemcacheDecodingError.unknownVerbReceived(messageVerb: verbString, messageBytes: peekableBuffer)
        }

        // Move the peekable buffer's readerIndex to after the verb so we can continue reading flags and/or data.
        peekableBuffer.moveReaderIndex(forwardBy: verbLength)

        if peekableBuffer.readableBytesView.first == .space {
            // Move the reader index to after the <space> that is following the verb
            peekableBuffer.moveReaderIndex(forwardBy: 1)
        }

        do {
            // Pass the entire buffer instead of the text line because .value messages continue after the first \r\n
            let result = try MemcacheBackendMessage.decode(from: &peekableBuffer, for: verb)

            // Message was read successfully, write new reader index back
            buffer = peekableBuffer

            // TODO: Can we make sure the message was read entirely? Difficult because we don't know the length of VA messages here.
            return result
        } catch _ as MemcacheNeedMoreDataError {
            // A message decoder expects more data. Try again.
            return nil
        } catch let error as MemcachePartialDecodingError {
            throw MemcacheDecodingError.withPartialError(error, messageVerb: verb.rawValue, messageBytes: peekableBuffer)
        } catch {
            preconditionFailure("Expected to only see `MemcachePartialDecodingError` here.")
        }
    }

    func decodeLast(buffer: inout ByteBuffer, seenEOF: Bool) throws -> MemcacheBackendMessage? {
        try self.decode(buffer: &buffer)
    }
}
