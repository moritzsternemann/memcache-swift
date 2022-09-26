import NIOCore
import NIOTestUtils
import XCTest

@testable import Memcache

final class MemcacheBackendMessageDecoderTests: XCTestCase {
    func testDecodeMessageWithAndWithoutFlags() {
        // TODO: Test decoding these messages also without flags. Test EN\r\n should fail when we receive it with flags.
        let flags: MemcacheBackendMessage.Flags = [.b, .R(0), .f]
        let expected: [MemcacheBackendMessage] = [
            .header(flags),
            .notFound(flags),
            .notStored(flags),
            .exists(flags),
            .end,
            .nonExistentCommandError,
            .clientError("Test Error"),
            .serverError("Test Error")
        ]

        let flagsString = "b R0 f"
        let messageString = [MemcacheBackendMessage.Verb]([.header, .notFound, .notStored, .exists])
            .map { "\($0.rawValue) \(flagsString)\r\n" }
            .joined()
            + "EN\r\n"
            + "ERROR\r\nCLIENT_ERROR Test Error\r\nSERVER_ERROR Test Error\r\n"

        XCTAssertNoThrow(try ByteToMessageDecoderVerifier.verifyDecoder(
            stringInputOutputPairs: [(messageString, expected)],
            decoderFactory: { MemcacheBackendMessageDecoder() }
        ))
    }

    func testDecodeValueMessageWithFlags() {
        var buffer = ByteBuffer()
        buffer.writeString("foo")
        let expected: [MemcacheBackendMessage] = [
            .value(.init(flags: [.b, .R(0), .f], data: buffer))
        ]

        XCTAssertNoThrow(try ByteToMessageDecoderVerifier.verifyDecoder(
            stringInputOutputPairs: [("VA 3 b R0 f\r\nfoo\r\n", expected)],
            decoderFactory: { MemcacheBackendMessageDecoder() }
        ))
    }

    func testDecodeValueMessageWithoutFlags() {
        var buffer = ByteBuffer()
        buffer.writeString("foo")
        let expected: [MemcacheBackendMessage] = [
            .value(.init(flags: [], data: buffer))
        ]

        XCTAssertNoThrow(try ByteToMessageDecoderVerifier.verifyDecoder(
            stringInputOutputPairs: [("VA 3\r\nfoo\r\n", expected)],
            decoderFactory: { MemcacheBackendMessageDecoder() }
        ))
    }

    func testDecodeMessageWithUnknownVerb() {
        XCTAssertThrowsError(try ByteToMessageDecoderVerifier.verifyDecoder(
            stringInputOutputPairs: [("XX T1 foo\r\n", [])],
            decoderFactory: { MemcacheBackendMessageDecoder() }
        )) {
            XCTAssert($0 is MemcacheDecodingError)
        }
    }
}
