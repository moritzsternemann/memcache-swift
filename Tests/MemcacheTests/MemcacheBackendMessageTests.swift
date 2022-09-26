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
        XCTAssertEqual(MemcacheBackendMessage.Verb(rawValue: "ERROR"), .nonExistentCommandError)
        XCTAssertEqual(MemcacheBackendMessage.Verb(rawValue: "CLIENT_ERROR"), .clientError)
        XCTAssertEqual(MemcacheBackendMessage.Verb(rawValue: "SERVER_ERROR"), .serverError)

        XCTAssertNil(MemcacheBackendMessage.Verb(rawValue: ""))
    }

    func testVerbHasCorrectRawValue() {
        XCTAssertEqual(MemcacheBackendMessage.Verb.header.rawValue, "HD")
        XCTAssertEqual(MemcacheBackendMessage.Verb.notFound.rawValue, "NF")
        XCTAssertEqual(MemcacheBackendMessage.Verb.notStored.rawValue, "NS")
        XCTAssertEqual(MemcacheBackendMessage.Verb.exists.rawValue, "EX")
        XCTAssertEqual(MemcacheBackendMessage.Verb.value.rawValue, "VA")
        XCTAssertEqual(MemcacheBackendMessage.Verb.end.rawValue, "EN")
        XCTAssertEqual(MemcacheBackendMessage.Verb.nonExistentCommandError.rawValue, "ERROR")
        XCTAssertEqual(MemcacheBackendMessage.Verb.clientError.rawValue, "CLIENT_ERROR")
        XCTAssertEqual(MemcacheBackendMessage.Verb.serverError.rawValue, "SERVER_ERROR")
    }

    func testDebugDescription() {
        XCTAssertEqual("\(MemcacheBackendMessage.header([.T(1), .v]))", ".header(flags: [.T(ttl: 1), .v])")
        XCTAssertEqual("\(MemcacheBackendMessage.notFound([.T(1), .v]))", ".notFound(flags: [.T(ttl: 1), .v])")
        XCTAssertEqual("\(MemcacheBackendMessage.notStored([.T(1), .v]))", ".notStored(flags: [.T(ttl: 1), .v])")
        XCTAssertEqual("\(MemcacheBackendMessage.exists([.T(1), .v]))", ".exists(flags: [.T(ttl: 1), .v])")
        XCTAssertEqual("\(MemcacheBackendMessage.value(.init(flags: [.T(1), .v], data: ByteBuffer())))", ".value(flags: [.T(ttl: 1), .v], data: )")
        XCTAssertEqual("\(MemcacheBackendMessage.end)", ".end")
        XCTAssertEqual("\(MemcacheBackendMessage.nonExistentCommandError)", ".nonExistentCommandError")
        XCTAssertEqual("\(MemcacheBackendMessage.clientError("Test Error"))", ".clientError(message: \"Test Error\")")
        XCTAssertEqual("\(MemcacheBackendMessage.serverError("Test Error"))", ".serverError(message: \"Test Error\")")
    }
}
