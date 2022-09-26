import ExtrasBase64
import NIOCore

struct MemcacheDecodingError: Error {
    let messageVerb: String
    let payload: String
    let description: String
    let file: String
    let line: UInt

    static func withPartialError(
        _ partialError: MemcachePartialDecodingError,
        messageVerb: String,
        messageBytes: ByteBuffer
    ) -> Self {
        MemcacheDecodingError(
            messageVerb: messageVerb,
            payload: String(base64Encoding: messageBytes.readableBytesView),
            description: partialError.description,
            file: partialError.file,
            line: partialError.line
        )
    }

    static func emptyMessageReceived(
        bytes: ByteBuffer,
        file: String = #fileID,
        line: UInt = #line
    ) -> Self {
        MemcacheDecodingError(
            messageVerb: "",
            payload: String(base64Encoding: bytes.readableBytesView),
            description: "Received an empty message (i.e. no characters before the first occurence of \r\n). A valid message has to contain a messageVerb at least.",
            file: file,
            line: line
        )
    }

    static func unknownVerbReceived(
        messageVerb: String,
        messageBytes: ByteBuffer,
        file: String = #fileID,
        line: UInt = #line
    ) -> Self {
        MemcacheDecodingError(
            messageVerb: messageVerb,
            payload: String(base64Encoding: messageBytes.readableBytesView),
            description: "Received a message with messageVerb '\(messageVerb)'. There is no message type associated with this message identifier.",
            file: file,
            line: line
        )
    }
}
