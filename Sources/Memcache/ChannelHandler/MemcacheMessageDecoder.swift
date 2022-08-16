//
//  MemcacheMessageDecoder.swift
//  
//
//  Created by Moritz Sternemann on 27.06.22.
//

import Foundation
import NIOCore

struct MemcacheMessageDecoder: NIOSingleStepByteToMessageDecoder {
    typealias InboundOut = MemcacheMetaResponse<String>

    func decode(buffer: inout ByteBuffer) throws -> MemcacheMetaResponse<String>? {
        guard let verb = buffer.readString(length: 2) else {
            // reader index wasn't moved, wait for more bytes
            return nil
        }

        switch verb {
        // header (HD <flags>*\r\n)
        case "HD":
            buffer.moveReaderIndex(forwardBy: 1) // <space>
            let flags = try decodeFlags(buffer: &buffer)
            buffer.moveReaderIndex(forwardBy: 1) // \r\n
            return .header(flags)

        // not found (NF <flags>*\r\n)
        case "NF":
            buffer.moveReaderIndex(forwardBy: 1) // <space>
            let flags = try decodeFlags(buffer: &buffer)
            buffer.moveReaderIndex(forwardBy: 1) // \r\n
            return .notFound(flags)

        // not stored (NS <flags>*\r\n)
        case "NS":
            buffer.moveReaderIndex(forwardBy: 1) // <space>
            let flags = try decodeFlags(buffer: &buffer)
            buffer.moveReaderIndex(forwardBy: 1) // \r\n
            return .notStored(flags)

        // exists (EX <flags>*\r\n)
        case "EX":
            buffer.moveReaderIndex(forwardBy: 1) // <space>
            let flags = try decodeFlags(buffer: &buffer)
            buffer.moveReaderIndex(forwardBy: 1) // \r\n
            return .exists(flags)

        // value (VA <size> <flags>*\r\n<data block>\r\n)
        case "VA":
            buffer.moveReaderIndex(forwardBy: 1) // <space>
            let response = try decodeValueResponse(buffer: &buffer)
            buffer.moveReaderIndex(forwardBy: 1) // \r\n
            return response

        // end (EN\r\n)
        case "EN":
            buffer.moveReaderIndex(forwardBy: 1) // \r\n
            return .end

        default:
            // TODO: parse responses like 'CLIENT_ERROR <reason>'
            return nil // TODO: maybe we want to throw an error instead
        }
    }

    func decodeLast(buffer: inout ByteBuffer, seenEOF: Bool) throws -> MemcacheMetaResponse<String>? {
        try decode(buffer: &buffer)
    }

    /// Try to read a string until `\r\n` and parse it to a `Set<String>` that contains the flags.
    ///
    /// Reader index will be after the last parsed flag
    private func decodeFlags(buffer: inout ByteBuffer) throws -> Set<String> {
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

        return Set(flagsString.components(separatedBy: " ")) // TODO: is the order of the flags important?
    }

    private func decodeValueResponse(buffer: inout ByteBuffer) throws -> MemcacheMetaResponse<String> {
        let bytes = buffer.readableBytesView

        let nextSpaceIndex = bytes.firstIndex(of: .space)
        let nextNewlineIndex = bytes.firstIndex(of: .newline)
        let sizeStringEndIndex: Int
        if let nextSpaceIndex = nextSpaceIndex,
           let nextNewlineIndex = nextNewlineIndex,
           nextSpaceIndex < nextNewlineIndex {
            // Flags after the size string
            sizeStringEndIndex = nextSpaceIndex - 1
        } else if let nextNewlineIndex = nextNewlineIndex {
            // No flags after the size string
            sizeStringEndIndex = nextNewlineIndex - 1
        } else {
            fatalError() // TODO: unexpected message format error
        }

        guard let sizeString = buffer.readString(length: sizeStringEndIndex - bytes.startIndex),
              let size = Int(sizeString)
        else {
            fatalError() // TODO: unexpected message format error
        }

        let flags: Set<String>
        if let nextSpaceIndex = nextSpaceIndex,
           let nextNewlineIndex = nextNewlineIndex,
           nextSpaceIndex < nextNewlineIndex {
            buffer.moveReaderIndex(forwardBy: 1) // <space>
            flags = try decodeFlags(buffer: &buffer)
        } else {
            flags = []
        }

        buffer.moveReaderIndex(forwardBy: 2) // \r\n
        guard let dataBlock = buffer.readSlice(length: size) else {
            fatalError() // TODO: Not enough data error
        }

        return .value(flags, dataBlock)
    }
}

extension UInt8 {
    fileprivate static let newline = UInt8(ascii: "\n")
    fileprivate static let carriageReturn = UInt8(ascii: "\r")
    fileprivate static let space = UInt8(ascii: " ")
}
