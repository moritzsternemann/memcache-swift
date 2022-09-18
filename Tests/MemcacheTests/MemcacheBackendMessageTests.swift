import NIOCore
import NIOTestUtils
import XCTest

@testable import Memcache

final class MemcacheBackendMessageTests: XCTestCase {
    func testInitVerbWithString() {
        XCTAssertEqual(MemcacheBackendMessage.Verb(rawValue: "HD"), .header)
        XCTAssertEqual(MemcacheBackendMessage.Verb(rawValue: "NF"), .notFound)
        XCTAssertEqual(MemcacheBackendMessage.Verb(rawValue: "NS"), .notStored)
        XCTAssertEqual(MemcacheBackendMessage.Verb(rawValue: "EX"), .exists)
        XCTAssertEqual(MemcacheBackendMessage.Verb(rawValue: "VA"), .value)
        XCTAssertEqual(MemcacheBackendMessage.Verb(rawValue: "EN"), .end)

        XCTAssertNil(MemcacheBackendMessage.Verb(rawValue: ""))
    }

    func testVerbHasCorrectRawValue() {
        XCTAssertEqual(MemcacheBackendMessage.Verb.header.rawValue, "HD")
        XCTAssertEqual(MemcacheBackendMessage.Verb.notFound.rawValue, "NF")
        XCTAssertEqual(MemcacheBackendMessage.Verb.notStored.rawValue, "NS")
        XCTAssertEqual(MemcacheBackendMessage.Verb.exists.rawValue, "EX")
        XCTAssertEqual(MemcacheBackendMessage.Verb.value.rawValue, "VA")
        XCTAssertEqual(MemcacheBackendMessage.Verb.end.rawValue, "EN")
    }

    func testDebugDescription() {
        XCTAssertEqual("\(MemcacheBackendMessage.header(["T1", "v"]))", #".header(["T1", "v"])"#)
        XCTAssertEqual("\(MemcacheBackendMessage.notFound(["T1", "v"]))", #".notFound(["T1", "v"])"#)
        XCTAssertEqual("\(MemcacheBackendMessage.notStored(["T1", "v"]))", #".notStored(["T1", "v"])"#)
        XCTAssertEqual("\(MemcacheBackendMessage.exists(["T1", "v"]))", #".exists(["T1", "v"])"#)
        XCTAssertEqual("\(MemcacheBackendMessage.value(.init(flags: ["T1", "v"], data: ByteBuffer())))", #".value(flags: ["T1", "v"], data: 0 bytes)"#)
        XCTAssertEqual("\(MemcacheBackendMessage.end)", ".end")
    }
}