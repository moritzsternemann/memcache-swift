//
//  MemcacheByteDecoder.swift
//  
//
//  Created by Moritz Sternemann on 27.06.22.
//

import Foundation
import NIOCore

final class MemcacheByteDecoder: ByteToMessageDecoder {
    typealias InboundOut = MemcacheResponse

    init() {}

    func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        guard let response = try parseBytes(from: &buffer) else { return .needMoreData }
        
        context.fireChannelRead(wrapInboundOut(response))
        return .continue
    }

    func decodeLast(context: ChannelHandlerContext, buffer: inout ByteBuffer, seenEOF: Bool) throws -> DecodingState {
        .needMoreData
    }
    
    private func parseBytes(from buffer: inout ByteBuffer) throws -> MemcacheResponse? {
        guard let response = parseResponseLine(from: &buffer) else { return nil }
        
        switch response {
        case "STORED":
            return .stored
        case "NOT_STORED":
            return .notStored
        case "EXISTS":
            return .exists
        case _ where response.hasPrefix("VALUE"):
            return parseValueResponse(response, buffer: &buffer)
        case "DELETED":
            return .deleted
        case "TOUCHED":
            return .touched
        case "NOT_FOUND":
            return .notFound
        default: // new value from incr/decr
            guard let newValue = buffer.readInteger(as: UInt64.self) else {
                fatalError()
            }
            return .newValue(newValue)
        }
    }
    
    private func parseResponseLine(from buffer: inout ByteBuffer) -> String? {
        let bytes = buffer.readableBytesView
        
        // Look for the \r\n in the response
        guard let newlineIndex = bytes.firstIndex(of: .newline),
              newlineIndex - bytes.startIndex >= 1
        else { return nil }
        
        // Move reader index to after \r\n
        defer {
            buffer.moveReaderIndex(to: newlineIndex + 1)
        }
        
        let endIndex = newlineIndex - bytes.startIndex
        return buffer.getString(at: bytes.startIndex, length: endIndex - 1)
    }
    
    private func parseValueResponse(_ firstResponseLine: String, buffer: inout ByteBuffer) -> MemcacheResponse {
        var responses: [MemcacheResponseValue] = []
        
        var responseLine = firstResponseLine
        while responseLine != "END" {
            let scanner = Scanner(string: responseLine)
            scanner.charactersToBeSkipped = .whitespaces
            guard let _ = scanner.scanUpToCharacters(from: .whitespaces), // VALUE keyword
                  let key = scanner.scanUpToCharacters(from: .whitespaces),
                  let flags = scanner.scanInt(),
                  let bytes = scanner.scanInt()
            else { fatalError() }
            
            let casUnique = scanner.scanUInt64()
            guard let dataBlock = buffer.getSlice(at: buffer.readerIndex, length: bytes) else {
                fatalError()
            }
            
            buffer.moveReaderIndex(forwardBy: bytes + 2) // data block length + final \r\n
            
            responses.append(.init(
                key: MemcacheKey(key),
                data: dataBlock,
                flags: UInt16(flags),
                bytes: UInt(bytes),
                casUnique: casUnique
            ))
            
            // check for END or next VALUE
            guard let nextResponseLine = parseResponseLine(from: &buffer) else {
                fatalError()
            }
            responseLine = nextResponseLine
        }
        
        return .values(responses)
    }
}

extension UInt8 {
    static let newline = UInt8(ascii: "\n")
}
